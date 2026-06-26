# aws_console.ps1

$profile = if ($env:AWS_PROFILE) { $env:AWS_PROFILE } else { "default" }

# Limpiar session token si existe
$credsFile = "$env:USERPROFILE\.aws\credentials"
(Get-Content $credsFile) | Where-Object { $_ -notmatch "aws_session_token" } | Set-Content $credsFile

Write-Host "Get federation token..."

$creds = aws sts get-federation-token `
  --name "console-session" `
  --duration-seconds 3600 `
  --policy '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}' `
  --profile $profile `
  --output json | ConvertFrom-Json

$accessKey   = $creds.Credentials.AccessKeyId
$secretKey   = $creds.Credentials.SecretAccessKey
$sessionToken = $creds.Credentials.SessionToken

$sessionJson = "{`"sessionId`":`"$accessKey`",`"sessionKey`":`"$secretKey`",`"sessionToken`":`"$sessionToken`"}"
$encoded = [Uri]::EscapeDataString($sessionJson)

$signinResponse = Invoke-RestMethod `
  "https://signin.aws.amazon.com/federation?Action=getSigninToken&Session=$encoded"

$signinToken = $signinResponse.SigninToken

$consoleUrl = "https://signin.aws.amazon.com/federation?Action=login&Issuer=my-script&Destination=https%3A%2F%2Fconsole.aws.amazon.com%2F&SigninToken=$signinToken"

Write-Host "`n✅ Opening AWS Console..."
Start-Process $consoleUrl