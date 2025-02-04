# Sync Images Tool
The `sync-images` tool can be used to synchronize a customer managed Azure ACR
registry with the latest Exocompute image bundle. The script will perform the
following operations, in order:

1. Fetch the latest image bundle from RSC, authentication is done using the RSC
   service account JSON file specified on the command line.
2. Pull and tag each image in the image bundle. The RSC container registry URL
   and image tag are both specified by the image bundle.
3. Push the tagged images to the registry specified on the command line.

A brief description of the command line options supported by the tool can be
found below:
```bash
usage: sync-images [OPTIONS]

Synchronize an Azure ACR container registry with the latest RSC Exocompute image bundle

The Azure application provided must be the application provided to RSC to access the
image bundles. The application also requires AcrPush access to the specified Azure ACR
registry.

Options:
-h, --help              Shows this help message
--azure-app-id          Azure application ID [REQUIRED]
--azure-app-secret      Azure application secret [REQUIRED]
--azure-tenant-id       Azure tenant ID [REQUIRED]
--azure-registry        URL (login server) of the Azure ACR registry [REQUIRED]
--rsc-service-account   RSC service account file [REQUIRED]
--namespace             Namespace in registry (e.g. rubrik) [REQUIRED]
--tag                   Override the tag specified in the image bundle [OPTIONAL]
```

> [!TIP]
> Pulling and pushing images sometimes time out. If this happens it's safe to
> simply restart the tool.
