# Production Master Script WITH Entra ID
<#
.SYNOPSIS
    Automated Hybrid Offboarding Workflow (Active Directory + Entra ID + Jira)
.DESCRIPTION
    1. Queries Jira Cloud for pending Offboarding tickets in a specified project with a populated target username.
    2. Disables the corresponding Active Directory user, strips secondary groups, and moves them to the Terminated Users OU.
    3. Authenticates to Microsoft Graph using App-Only credentials, disables the cloud user, and revokes active sessions.
    4. Posts an audit comment back to the Jira ticket and transitions its status to Resolved.
#>

# Requires -Modules ActiveDirectory, Microsoft.Graph.Users

# ----------------------------------------------------------------------
# 1. CONFIGURATION PARAMETERS (UPDATE THESE)
# ----------------------------------------------------------------------
$JiraDomain      = "your-jira-domain"           # e.g., "mycompany" (from mycompany.atlassian.net)
$UserEmail       = "your-email@example.com"     # Jira account email
$ApiToken        = "YOUR_JIRA_API_TOKEN"        # Atlassian API Token
$EmailFieldId    = "customfield_XXXXX"          # Custom Field ID for Target Username
$TargetProject   = "YOUR_PROJECT_KEY"           # e.g., "IO" or "IT"

# Target Active Directory OU for Terminated Users
$TerminatedOU    = "OU=Terminated Users,DC=yourdomain,DC=local"

# Entra ID (Microsoft Graph) App-Only Configuration
$TenantId        = "YOUR_TENANT_ID"             # From Entra ID Overview
$ClientId        = "YOUR_CLIENT_ID"             # From App Registration Overview
$ClientSecret    = "YOUR_CLIENT_SECRET"         # The secret value copied upon creation
$CloudDomain     = "yourtenant.onmicrosoft.com" # Your cloud tenant domain suffix

# Log Directory & File Path
$LogFolder       = "C:\Automation\Logs"
$LogFilePath     = Join-Path -Path$LogFolder -ChildPath "Offboarding_Master.log"

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
    $FormattedMessage = "[$Timestamp] [$Level]$Message"
    
    switch ($Level) {
        "SUCCESS" { Write-Host $FormattedMessage -ForegroundColor Green }
        "WARNING" { Write-Host $FormattedMessage -ForegroundColor Yellow } "ERROR"   { Write-Host $
