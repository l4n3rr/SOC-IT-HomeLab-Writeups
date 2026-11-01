# Project Finder Diagnostic Script

<#
.SYNOPSIS
    Discovers all available Jira projects, keys, and IDs.
#>

$JiraDomain = "your-jira-domain"
$UserEmail  = "your-email@example.com"
$ApiToken   = "YOUR_API_TOKEN"

$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${UserEmail}:${ApiToken}"))
$Headers = @{
    "Authorization" = "Basic $Base64Auth"
    "Accept"        = "application/json"
}

$ProjectsUrl = "https://$JiraDomain.atlassian.net/rest/api/3/project"

try {
    $Projects = Invoke-RestMethod -Uri $ProjectsUrl -Method Get -Headers $Headers
    Write-Host "`n--- Available Projects in Jira ---" -ForegroundColor Yellow
    foreach ($P in $Projects) {
        Write-Host "Name: $($P.name) | Key: '$($P.key)' | ID: $($P.id)" -ForegroundColor Cyan
    }
}
catch {
    Write-Host "Error listing projects: $_" -ForegroundColor Red
}
