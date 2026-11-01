# Transition Checker Diagnostic Script

<#
.SYNOPSIS
    Queries available workflow transition IDs, names, and destination statuses for a specific ticket.
#>

$JiraDomain = "your-jira-domain"
$UserEmail  = "your-email@example.com"
$ApiToken   = "YOUR_API_TOKEN"
$IssueKey   = "YOUR_ISSUE_KEY" # e.g., "IO-1"

$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${UserEmail}:${ApiToken}"))
$Headers = @{
    "Authorization" = "Basic $Base64Auth"
    "Accept"        = "application/json"
}

$TransitionUrl = "https://$JiraDomain.atlassian.net/rest/api/3/issue/$IssueKey/transitions"

try {
    $Resp = Invoke-RestMethod -Uri $TransitionUrl -Method Get -Headers $Headers
    Write-Host "`n--- Available Transitions for $IssueKey ---" -ForegroundColor Yellow
    foreach ($t in $Resp.transitions) {
        Write-Host "ID: $($t.id)  |  Name: '$($t.name)'  |  To Status: '$($t.to.name)'" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "Error fetching transitions: $_" -ForegroundColor Red
}
