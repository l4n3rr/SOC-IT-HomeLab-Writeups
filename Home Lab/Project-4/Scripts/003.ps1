# Project Issue Diagnostic Script

<#
.SYNOPSIS
    Lists all issues in a specific project with zero filters to inspect field metadata and statuses.
#>

$JiraDomain   = "your-jira-domain"
$UserEmail    = "your-email@example.com"
$ApiToken     = "YOUR_API_TOKEN"
$TargetProject= "YOUR_PROJECT_KEY"
$EmailFieldId = "customfield_XXXXX"

$Base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${UserEmail}:${ApiToken}"))
$Headers = @{
    "Authorization" = "Basic $Base64Auth"
    "Accept"        = "application/json"
}

$JqlQuery  = "project = '$TargetProject'"
$SearchUrl = "https://$JiraDomain.atlassian.net/rest/api/3/search/jql?jql=$([uri]::EscapeDataString($JqlQuery))&fields=summary,issuetype,status,$EmailFieldId"

try {
    $Response = Invoke-RestMethod -Uri $SearchUrl -Method Get -Headers $Headers
    Write-Host "`nFound $($Response.issues.Count) total issue(s) in Project $TargetProject.`n" -ForegroundColor Yellow

    foreach ($Issue in $Response.issues) {
        Write-Host "Ticket Key : $($Issue.key)" -ForegroundColor Cyan
        Write-Host "Summary    : $($Issue.fields.summary)"
        Write-Host "Issue Type : '$($Issue.fields.issuetype.name)'"
        Write-Host "Status     : '$($Issue.fields.status.name)'"
        Write-Host "Username   : $($Issue.fields.$EmailFieldId)"
        Write-Host "---------------------------------------------------"
    }
}
catch {
    Write-Host "Error: $_" -ForegroundColor Red
}
