#!/bin/bash
set -e

PROFILE="${AWS_PROFILE:-default}"
DURATION=18000
SESSION_NAME="console-session"

echo "get federation token..."

CREDS=$(aws sts get-federation-token \
  --name "$SESSION_NAME" \
  --duration-seconds "$DURATION" \
  --policy '{"Version":"2012-10-17","Statement":[{"Effect":"Allow","Action":"*","Resource":"*"}]}' \
  --profile "$PROFILE" \
  --output json)

ACCESS_KEY=$(echo "$CREDS" | jq -r '.Credentials.AccessKeyId')
SECRET_KEY=$(echo "$CREDS" | jq -r '.Credentials.SecretAccessKey')
SESSION_TOKEN=$(echo "$CREDS" | jq -r '.Credentials.SessionToken')

SESSION_JSON=$(printf '{"sessionId":"%s","sessionKey":"%s","sessionToken":"%s"}' \
  "$ACCESS_KEY" "$SECRET_KEY" "$SESSION_TOKEN")

ENCODED_SESSION=$(python3 -c "import urllib.parse, sys; print(urllib.parse.quote(sys.argv[1]))" "$SESSION_JSON")

SIGNIN_RESPONSE=$(curl -s \
  "https://signin.aws.amazon.com/federation?Action=getSigninToken&SessionDuration=$DURATION&Session=$ENCODED_SESSION")

SIGNIN_TOKEN=$(echo "$SIGNIN_RESPONSE" | jq -r '.SigninToken')

CONSOLE_URL="https://signin.aws.amazon.com/federation?Action=login&Issuer=my-script&Destination=https%3A%2F%2Fconsole.aws.amazon.com%2F&SigninToken=$SIGNIN_TOKEN"

echo ""
echo "✅ URL:"
echo "$CONSOLE_URL"

# Open in browser (depending on OS)
case "$(uname -s)" in
  Linux*)   xdg-open "$CONSOLE_URL" 2>/dev/null || echo "Manually open the URL" ;;
  Darwin*)  open "$CONSOLE_URL" ;;
  CYGWIN*|MINGW*|MSYS*) cmd.exe /c start "$CONSOLE_URL" ;;
  *)        echo "Unrecognized OS, manually open the URL" ;;
esac
