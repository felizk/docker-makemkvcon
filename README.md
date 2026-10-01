Sorry, this is just my play project for creating a console version of the wonderful makemkv docker.

I added a few tools too for working with MKV files.

I didn't realize this repo was public, oh well. 

## Image variants

Two variants are published to `ghcr.io/felizk/docker-makemkvcon`:

| Tag | Base image |
|-----|------------|
| `master`, `vX.Y.Z`, `latest` | `mcr.microsoft.com/dotnet/runtime:10.0-alpine` |
| `master-aspnet`, `vX.Y.Z-aspnet`, `latest-aspnet` | `mcr.microsoft.com/dotnet/aspnet:10.0-alpine` |

To build the aspnet variant locally:

    docker build --build-arg BASE_IMAGE=mcr.microsoft.com/dotnet/aspnet:10.0-alpine .
