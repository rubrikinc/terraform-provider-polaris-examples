# Account Module
The account module onboards an AWS account to RSC using the `polaris_aws_cnp_*`
TF resources. The module also creates the required AWS IAM roles. Note, the
`rsc_features` variable must at a minimum contain the following feature with the
`BASIC` permission group:
```hcl
rsc_features = [
  {
    name              = "EXOCOMPUTE"
    permission_groups = ["BASIC"]
  }
]
```
