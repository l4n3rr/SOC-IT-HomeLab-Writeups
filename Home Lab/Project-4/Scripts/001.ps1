# Production Master Script BEFORE Entra ID PART
<#
.SYNOPSIS
    Automated Single-Script Offboarding Workflow
.DESCRIPTION
    1. Queries Jira Cloud for pending Offboarding tickets in a specified project with a populated target username.
    2. Disables the corresponding Active Directory user, strips secondary groups, and moves them to the Terminated Users OU.
    3. Gracefully attempts Entra ID account disablement.
    4. Posts an audit comment back to the Jira ticket and transitions its status to Resolved.
#>

# Requires -Modules ActiveDirectory

# ----------------------------------------------------------------------
# 1. CONFIGURATION PARAMETERS (UPDATE THESE)
# ----------------------------------------------------------------------
$JiraDomain      = "your-jira-domain"         # e.g., "mycompany" (from mycompany.atlassian.net)
$UserEmail       = "your-email@example.com"   # Jira account email
$ApiToken        = "YOUR_API_TOKEN"           # Atlassian API Token
$EmailFieldId    = "customfield_XXXXX"        # Custom Field ID for Target Username / Employee Email
$TargetProject   = "YOUR_PROJECT_KEY"         # e.g., "IO" or "IT"

# Target Active Directory OU for Terminated Users
$TerminatedOU    = "OU=Terminated Users,DC=yourdomain,DC=local"

# Log Directory & File Path
$LogFolder       = "C:\Automation\Logs"
$LogFilePath     = Join-Path -Path $LogFolder -ChildPath "Offboarding_Master.log"

# ----------------------------------------------------------------------
# 2. LOGGING HELPER FUNCTION
# ----------------------------------------------------------------------
if (-not (Test-Path -Path $LogFolder)) {
    New-Item -Path $LogFolder -ItemType Directory -Force | Out-Null
}

function Write-Log {
    param (
        [string]$Message,
        [ValidateSet("INFO", "SUCCESS", "WARNING", "ERROR")]
        [string]$Level = "INFO"
    )
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $FormattedMessage = "[$Timestamp] [$Level] $Message"
    
    switch ($Level) {
        "SUCCESS" { Write-Host $FormattedMessage -ForegroundColor Green }
        "WARNING" { Write-Host $FormattedMessage -ForegroundColor Yellow }
        "ERROR"   { Write-Host $FormattedMessage -ForegroundColor Red }
        default   { Write-Host $FormattedMessage -ForegroundColor Cyan }
    }
    Add-Content -Path $LogFilePath -Value $FormattedMessage
}

Write-Log "==================================================" "INFO"
Write-Log "Starting Automated Offboarding Workflow Processing" "INFO"

# ----------------------------------------------------------------------
# 3. JIRA API AUTHENTICATION & QUERY SETUP
# ----------------------------------------------------------------------
$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${UserEmail}:${ApiToken}"))
$Headers = @{
    "Authorization" = "Basic $Base64Auth"
    "Accept"        = "application/json"
}

$JqlQuery  = "project = '$TargetProject' AND status != 'Done' AND $EmailFieldId IS NOT EMPTY AND summary ~ 'Offboarding'"
$SearchUrl = "https://$JiraDomain.atlassian.net/rest/api/3/search/jql?jql=$([uri]::EscapeDataString($JqlQuery))&fields=summary,status,$EmailFieldId"

# ----------------------------------------------------------------------
# 4. FETCH TICKETS FROM JIRA
# ----------------------------------------------------------------------
try {
    Write-Log "[Jira] Querying pending tickets..." "INFO"
    $Response = Invoke-RestMethod -Uri $SearchUrl -Method Get -Headers $Headers
    $Tickets  = $Response.issues

    if (-not $Tickets -or $Tickets.Count -eq 0) {
        Write-Log "[Jira] No pending offboarding tickets found matching criteria." "INFO"
        exit
    }
    Write-Log "[Jira] Found $($Tickets.Count) ticket(s) to process." "SUCCESS"
}
catch {
    Write-Log "[Jira ERROR] Failed to fetch tickets: $_" "ERROR"
    exit
}

# ----------------------------------------------------------------------
# 5. PROCESS EACH TICKET
# ----------------------------------------------------------------------
foreach ($Issue in $Tickets) {
    $IssueKey       = $Issue.key
    $Summary        = $Issue.fields.summary
    $TargetUsername = $Issue.fields.$EmailFieldId

    Write-Log "--------------------------------------------------" "INFO"
    Write-Log "Processing Ticket [$IssueKey] - Summary: $Summary" "INFO"

    if (-not $TargetUsername) {
        Write-Log "[Jira WARNING] Ticket [$IssueKey] has a blank Target Username. Skipping." "WARNING"
        continue
    }

    # --- A. ACTIVE DIRECTORY OFFBOARDING ---
    try {
        $ADUser = Get-ADUser -Identity $TargetUsername -ErrorAction Stop
        Write-Log "[AD] User account found: $($ADUser.DistinguishedName)" "INFO"

        Set-ADUser -Identity $ADUser -Enabled $false
        Write-Log "[AD] Account '$TargetUsername' has been disabled." "SUCCESS"

        $UserGroups = Get-ADPrincipalGroupMembership -Identity $TargetUsername | Where-Object { $_.isGroupMemberOfPrimaryGroup -ne $true }
        foreach ($Group in $UserGroups) {
            Remove-ADGroupMember -Identity $Group -Members $TargetUsername -Confirm:$false
            Write-Log "[AD] Removed '$TargetUsername' from group: $($Group.Name)" "INFO"
        }

        Move-ADObject -Identity $ADUser.DistinguishedName -TargetPath $TerminatedOU
        Write-Log "[AD] Successfully moved '$TargetUsername' to OU: $TerminatedOU" "SUCCESS"
    }
    catch {
        Write-Log "[AD ERROR] Failed to offboard user '$TargetUsername': $_" "ERROR"
        continue
    }

    # --- B. ENTRA ID OFFBOARDING (GRACEFUL SKIPPING) ---
    try {
        if (Get-Command -Name Update-MgUser -ErrorAction SilentlyContinue) {
            Write-Log "[Entra ID] Disablement command skipped (Entra ID integration pending)." "INFO"
        }
        else {
            Write-Log "[Entra ID] Microsoft Graph module not present. Skipping cloud disablement." "INFO"
        }
    }
    catch {
        Write-Log "[Entra ID WARNING] Entra ID offboarding warning: $_" "WARNING"
    }

    # --- C. JIRA COMMENT & STATUS TRANSITION ---
    try {
        $CommentUrl    = "https://$JiraDomain.atlassian.net/rest/api/3/issue/$IssueKey/comment"
        $TransitionUrl = "https://$JiraDomain.atlassian.net/rest/api/3/issue/$IssueKey/transitions"

        $CommentBody = @{
            body = @{
                type    = "doc"
                version = 1
                content = @(
                    @{
                        type    = "paragraph"
                        content = @(
                            @{
                                type = "text"
                                text = "Automated Offboarding Completed: Account '$TargetUsername' has been disabled, stripped of secondary groups, and moved to '$TerminatedOU' in Active Directory."
                            }
                        )
                    }
                )
            }
        } | ConvertTo-Json -Depth 10

        Invoke-RestMethod -Uri $CommentUrl -Method Post -Headers $Headers -Body $CommentBody -ContentType "application/json" | Out-Null
        Write-Log "[Jira] Posted success confirmation comment to ticket [$IssueKey]." "SUCCESS"

        $TransitionsResp = Invoke-RestMethod -Uri $TransitionUrl -Method Get -Headers $Headers
        $DoneTransition  = $TransitionsResp.transitions | Where-Object { 
            $_.name -match 'Resolve|Done|Close' -or $_.to.name -match 'Resolved|Done|Closed' 
        } | Select-Object -First 1

        if ($DoneTransition) {
            $TransitionBody = @{
                transition = @{ id = $DoneTransition.id }
            } | ConvertTo-Json -Depth 5

            try {
                Invoke-RestMethod -Uri $TransitionUrl -Method Post -Headers $Headers -Body $TransitionBody -ContentType "application/json" | Out-Null
                Write-Log "[Jira] Successfully transitioned ticket [$IssueKey] via '$($DoneTransition.name)' to status: '$($DoneTransition.to.name)'." "SUCCESS"
            }
            catch {
                $TransitionBodyWithResolution = @{
                    transition = @{ id = $DoneTransition.id }
                    fields     = @{ resolution = @{ name = "Done" } }
                } | ConvertTo-Json -Depth 5
                
                Invoke-RestMethod -Uri $TransitionUrl -Method Post -Headers $Headers -Body $TransitionBodyWithResolution -ContentType "application/json" | Out-Null
                Write-Log "[Jira] Successfully transitioned ticket [$IssueKey] with resolution." "SUCCESS"
            }
        }
        else {
            Write-Log "[Jira WARNING] Could not find a 'Resolve' or 'Done' transition state for ticket [$IssueKey]." "WARNING"
        }
    }
    catch {
        Write-Log "[Jira ERROR] Failed to comment or update ticket status for [$IssueKey]: $_" "ERROR"
    }
}

Write-Log "==================================================" "INFO"
Write-Log "Automated Offboarding Task Run Finished." "INFO"
