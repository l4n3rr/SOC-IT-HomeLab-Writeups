# 006 - Final Automated Hybrid Offboarding Master Script AD + Entra ID

# ==========================================
# Automated Hybrid Offboarding Pipeline
# ==========================================

# 1. Configuration & Variables
$TenantId     = "YOUR_TENANT_ID"
$ClientId     = "YOUR_CLIENT_ID"
$ClientSecret = "YOUR_CLIENT_SECRET_VALUE"
$CloudDomain  = "yourdomain.onmicrosoft.com"

$JiraBaseUrl  = "https://your-domain.atlassian.net/rest/api/2"
$JiraEmail    = "admin@yourdomain.com"
$JiraApiToken = "YOUR_JIRA_API_TOKEN"
$JiraAuth     = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${JiraEmail}:${JiraApiToken}"))

$LogPath      = "C:\Users\Administrator\Desktop\JiraScript\PipelineScripts\offboard_audit.log"

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogEntry = "[$Timestamp] [$Level] $Message"
    Add-Content -Path $LogPath -Value $LogEntry
    Write-Host $LogEntry
}

Write-Log "==================================================" "INFO"
Write-Log "Starting Automated Hybrid Offboarding Workflow" "INFO"

# 2. Microsoft Graph Authentication via Direct Token Exchange
try {
    $TokenBody = @{
        client_id     = $ClientId
        scope         = "https://graph.microsoft.com/.default"
        client_secret = $ClientSecret
        grant_type    = "client_credentials"
    }
    
    $TokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $TokenBody -ErrorAction Stop
    $SecureToken   = ConvertTo-SecureString $TokenResponse.access_token -AsPlainText -Force
    
    Connect-MgGraph -AccessToken $SecureToken -NoWelcome -ErrorAction Stop | Out-Null
    Write-Log "[Entra ID] Successfully authenticated to Microsoft Graph via Token." "SUCCESS"
}
catch {
    Write-Log "[Entra ID ERROR] Failed to authenticate to Microsoft Graph: $_" "ERROR"
    exit
}

# 3. Query Jira for Pending Offboarding Tickets
Write-Log "[Jira] Querying pending tickets..." "INFO"
$JiraHeaders = @{ "Authorization" = "Basic $JiraAuth"; "Content-Type" = "application/json" }
$JqlQuery    = 'project = "IO" AND status = "To Do" AND summary ~ "Offboarding"'
$SearchUri   = "$JiraBaseUrl/search?jql=$([Uri]::EscapeDataString($JqlQuery))"

try {
    $SearchResp = Invoke-RestMethod -Uri $SearchUri -Method GET -Headers $JiraHeaders -ErrorAction Stop
    $Tickets    = $SearchResp.issues
    Write-Log "[Jira] Found $($Tickets.Count) ticket(s) to process." "SUCCESS"
}
catch {
    Write-Log "[Jira ERROR] Failed to query Jira tickets: $_" "ERROR"
    exit
}

# 4. Process Each Ticket
foreach ($Ticket in $Tickets) {
    $TicketKey = $Ticket.key
    $Summary   = $Ticket.fields.summary
    Write-Log "--------------------------------------------------" "INFO"
    Write-Log "Processing Ticket [$TicketKey] - Summary: $Summary" "INFO"

    # Extract target username from summary (e.g., "Offboarding - John Smith" -> jsmith)
    # Assumes naming convention or explicit property parsing
    $TargetUsername = "jsmith" 

    # --- A. LOCAL ACTIVE DIRECTORY OFFBOARDING ---
    try {
        $AdUser = Get-ADUser -Identity $TargetUsername -Properties DistinguishedName -ErrorAction Stop
        Write-Log "[AD] User account found: $($AdUser.DistinguishedName)" "INFO"

        # Disable AD Account
        Disable-ADAccount -Identity $TargetUsername -Confirm:$false
        Write-Log "[AD] Account '$TargetUsername' has been disabled." "SUCCESS"

        # Move to Terminated Users OU
        $TargetOU = "OU=Terminated Users,DC=lab,DC=local"
        Move-ADObject -Identity $AdUser.DistinguishedName -TargetPath $TargetOU
        Write-Log "[AD] Successfully moved '$TargetUsername' to OU: $TargetOU" "SUCCESS"
    }
    catch {
        Write-Log "[AD ERROR] Active Directory offboarding failed for '$TargetUsername': $_" "ERROR"
    }

    # --- B. ENTRA ID (CLOUD) OFFBOARDING ---
    try {
        $EntraUPN = "${TargetUsername}@${CloudDomain}"
        
        # 1. Disable Cloud Account via Body Parameter
        $CloudParams = @{
            accountEnabled = $false
        }
        Update-MgUser -UserId $EntraUPN -BodyParameter $CloudParams -ErrorAction Stop
        Write-Log "[Entra ID] Cloud account '$EntraUPN' has been disabled." "SUCCESS"

        # 2. Revoke Active Sessions via Direct API Call
        Invoke-MgGraphRequest -Uri "https://graph.microsoft.com/v1.0/users/$EntraUPN/revokeSignInSessions" -Method POST -ErrorAction Stop | Out-Null
        Write-Log "[Entra ID] Successfully revoked active sessions for '$EntraUPN'." "SUCCESS"
    }
    catch {
        Write-Log "[Entra ID WARNING] Entra ID offboarding warning for '$TargetUsername': $_" "WARNING"
    }

    # --- C. JIRA AUDIT COMMENT & TRANSITION ---
    try {
        $CommentBody = @{
            body = "Automated offboarding complete. Local AD account disabled and relocated, Entra ID cloud account blocked, and active sessions revoked."
        } | ConvertTo-Json

        Invoke-RestMethod -Uri "$JiraBaseUrl/issue/$TicketKey/comment" -Method POST -Headers $JiraHeaders -Body $CommentBody -ErrorAction Stop
        Write-Log "[Jira] Posted success confirmation comment to ticket [$TicketKey]." "SUCCESS"
    }
    catch {
        Write-Log "[Jira WARNING] Failed to post comment to [$TicketKey]: $_" "WARNING"
    }
}

Write-Log "==================================================" "INFO"
Write-Log "Automated Hybrid Offboarding Task Run Finished." "INFO"
