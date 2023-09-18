# Adding AWS account with MFA to RSC
Use the [AWS CLI tool](https://aws.amazon.com/cli) to obtain a temporary set of credentials. Create a temporary profile
in `~/.aws/credentials` from these credentials or export them as environment variables. Finally, set the profile in the
Terraform configuration to either the previously created temporary profile or _default_ if the temporary credentials
have been exported as environment variables.

## Obtaining temporary credentials
Use the [aws sts get-session-token](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/sts/get-session-token.html)
command to obtain the set of temporary credentials. The basic command looks like this:
```bash
aws sts get-session-token --serial-number arn-of-the-mfa-device --token-code code-from-token
```
Where `--serial-number` specifies the ARN of your MFA device and `--token-code` is the current token displayed on your
MFA device.

As an example, let's assume we have a local profile called `my-profile`, identifying a user with MFA within the
account we want to add to RSC, and the ARN of our MFA device is `arn:aws:iam::123456789012:mfa/my-authenticator` and the
current MFA token code is `123456`. The following command would then be used to obtain the temporary credentials:
```bash
aws sts get-session-token --profile my-profile --serial-number arn:aws:iam::123456789012:mfa/my-authenticator --token-code 123456
```

The result from running the `aws sts get-session-token` command is a JSON message with the following structure:
```json
{
    "Credentials": {
        "AccessKeyId": "<redacted-aws-access-key-id>",
        "SecretAccessKey": "<redacted-aws-secret-access-key>",
        "SessionToken": "<redacted-aws-session-token>",
        "Expiration": "2023-02-14T20:34:46Z"
    }
}
```
The values of `AccessKeyId`, `SecretAccessKey` and `SessionToken` should be used to either create a new temporary
profile:
```ini
[my-temp-profile]
aws_access_key_id = <redacted-aws-access-key-id>
aws_secret_access_key = <redacted-aws-secret-access-key>
aws_session_token = <redacted-aws-session-token>
```
Or be exported as environment variables:
```bash
export AWS_ACCESS_KEY_ID=<redacted-aws-access-key-id>
export AWS_SECRET_ACCESS_KEY=<redacted-aws-secret-access-key>
export AWS_SESSION_TOKEN=<redacted-aws-session-token>
```
Note that the Terraform provider still needs a default region, this is where the CloudFormation stack will be created.
If a temporary profile has been created, set the default region for that profile in `~/.aws/config`. If the temporary
credentials have been exported as environment variables, set the default region using the environment variable
`AWS_REGION`.

Additional documentation can be found [here](https://aws.amazon.com/premiumsupport/knowledge-center/authenticate-mfa-cli/).
