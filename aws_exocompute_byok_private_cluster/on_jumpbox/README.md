# On Jumpbox Configuration
This configuration is deployed to an AWS EC2 instance by the jumpbox module in
the on_host configuration. The purpose of the configuration is to apply one of
the two manifest modules, finishing the setup of the Exocompute EKS cluster.

To use the `kubectl` command manually on the jumpbox, use the provided
`kubeconfig` configuration file in the `on_jumpbox` directory:
```bash
kubectl --kubeconfig=kubeconfig get pods -A
```

> [!INFO]
> The Terraform state for the configuration is stored in an AWS S3 bucket so it
> survives if the EC2 instance gets recreated.
