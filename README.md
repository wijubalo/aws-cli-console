<<<<<<< HEAD
# AWS Console Access via CLI Credentials

Scripts to generate an AWS Console access URL using programmatic credentials (`aws_access_key_id` / `aws_secret_access_key`), without needing direct IAM console access.

## How it works

Uses the AWS federation endpoint (`signin.aws.amazon.com/federation`) to convert permanent IAM credentials into a temporary session URL valid for the AWS web console.

## Requirements

### Linux / Mac
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- `jq` — `sudo apt install jq` / `brew install jq`
- `python3` (usually pre-installed)
- `curl`

### Windows
- [AWS CLI v2](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2-windows.html)
- PowerShell 5.1 or higher (included in Windows 10+)

## Credentials setup

Configure an AWS profile with your permanent credentials:

```bash
aws configure --profile PROFILE_NAME
```

Enter when prompted:
```
AWS Access Key ID: AKIA...
AWS Secret Access Key: xxxxx
Default region name: us-east-1
Default output format: json
```

> ⚠️ Credentials must be permanent (the `aws_access_key_id` starts with `AKIA`). Temporary credentials (`ASIA`) are not supported.

Verify they work correctly:

```bash
aws sts get-caller-identity --profile PROFILE_NAME
```

## Usage

### Linux / Mac

```bash
chmod +x aws_console.sh
AWS_PROFILE=PROFILE_NAME ./aws_console.sh
```

### Windows (PowerShell)

```powershell
$env:AWS_PROFILE="PROFILE_NAME"; .\aws_console.ps1
```

The script will automatically open the AWS Console in your default browser.

## Session duration

The session lasts **1 hour** by default. When it expires, simply run the script again to get a new URL.

To extend the duration (maximum 36 hours), edit the `DURATION` variable in the script:

```bash
# aws_console.sh
DURATION=129600  # 36 hours
```

```powershell
# aws_console.ps1
$duration = 129600
```

## Troubleshooting

| Error | Cause | Solution |
|---|---|---|
| `Cannot call GetFederationToken with session credentials` | Profile has an `aws_session_token` | Remove the `aws_session_token` line from `~/.aws/credentials` |
| `InvalidClientTokenId` | Incorrect or incomplete credentials | Verify your `access_key_id` and `secret_access_key` were copied correctly |
| `AccessDenied` | User lacks `sts:GetFederationToken` permission | Contact your administrator to grant that permission |
| `ExpiredToken` | The `aws_session_token` has expired | Remove the `aws_session_token` line from `~/.aws/credentials` |
| URL opens but shows "Only federation tokens..." | Temporary credentials (`ASIA`) were used | Use permanent credentials (`AKIA`) instead |
=======
# aws-cli-console
AWS Console Access via CLI Credentials
>>>>>>> 6a056269ae38029a959571c79fb59f01ce9b0d5e
