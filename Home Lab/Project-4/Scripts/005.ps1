# 005 - Entra ID OAuth Token Diagnostic Script

$TenantId     = "YOUR_TENANT_ID"
$ClientId     = "YOUR_CLIENT_ID"
$ClientSecret = "YOUR_CLIENT_SECRET_VALUE"

$TokenBody = @{
    client_id     = $ClientId
    scope         = "https://graph.microsoft.com/.default"
    client_secret = $ClientSecret
    grant_type    = "client_credentials"
}

try {
    $Response = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$TenantId/oauth2/v2.0/token" -Method POST -Body $TokenBody -ErrorAction Stop
    Write-Host "[SUCCESS] OAuth token acquired successfully!" -ForegroundColor Green
    $Response.access_token
}
catch {
    Write-Host "[ERROR] Token Request Failed:" -ForegroundColor Red
    $_.ErrorDetails.Message
}

