# Sync Images Tool
The `sync-images` tool can be used to synchronize a customer managed AWS ECR
registry with the latest Exocompute image bundle. The script will perform the
following operations, in order:

1. Fetch the latest image bundle from RSC, authentication is done using the RSC
   service account JSON file specified on the command line.
2. Create an AWS ECR repository per image in the image bundle. The repositories
   are created in the registry and namespace specified on the command line.
3. Pull and tag each image in the image bundle. The RSC container registry URL
   and image tag are both specified by the image bundle.
4. Push the tagged images to the repositories created in step 2.

A brief description of the command line options supported by the tool can be
found below:
```bash
usage: sync-images [OPTIONS]

Synchronize an AWS ECR registry with the latest RSC Exocompute image bundle

Options:
-a, --abort-on-error    Abort when creating an ECR repository fails, ignored by default to allow for existing repositories
-h, --help              Shows this help message
-s, --service-account   RSC service account file [REQUIRED]
-r, --registry          URL of ECR registry where repositories will be created (e.g. 123456789012.dkr.ecr.us-east-1.amazonaws.com) [REQUIRED]
-n, --namespace         Namespace of ECR repositories (e.g. rsc) [REQUIRED]
-e, --eks-version       Version of the EKS cluster using the ECR registry (e.g. 1.29) [REQUIRED]
-t, --tag               Override the tag specified in the image bundle [OPTIONAL]
```
The `-s`, `-r`, `-n` and `-e` command line options are all required when running the tool.

> [!TIP]
> Pulling and pushing images sometimes time out. If this happens it's safe to
> simply restart the tool.
