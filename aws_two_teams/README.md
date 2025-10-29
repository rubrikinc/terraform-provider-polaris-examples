# AWS Two Teams Example

This example shows how the AWS roles required by RSC and the AWS account onboarding to RSC can be managed by two
different teams. In the example, team 1 manages the AWS roles and team 2 onboards the AWS account to RSC.

## Notes

This example uses a hardcoded trust policy for each role. When the RSC requirements on trust policies changes or new
roles with new trust policies are introduced, the hardcoded trust policies must be updated.

Since the trust policies are hardcoded, there is no dependency between the trust policies and the onboarded AWS account.
This means it's possible to offboard an AWS account without Terraform first destroying the trust policies. This in turn
means that RSC will have access to the AWS cloud environment when the account is being offboarded, so RSC will be able
to delete snapshots if requested using the `delete_snapshots_on_destroy` field of the `polaris_aws_cnp_account`
resource.

When the AWS permissions needed by RSC changes, and the cloud account moves into the missing permissions state, both
teams need to re-apply their Terraform configurations to move the cloud account back to the connected state again.
Team 1 to update the AWS roles and team 2 to notify RSC about the roles having been updated.

Both teams require an RSC service account to authenticate with RSC. Team 1 needs to access RSC to obtain information
about the roles and their permissions. Team 2 needs to access RSC to onboard the AWS account.
