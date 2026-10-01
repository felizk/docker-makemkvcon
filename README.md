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

## Registration key

`/defaults/settings.conf` is a template for `~/.MakeMKV/settings.conf`. It holds
the beta key that was current when the image was built, which expires after a
while. Nothing in the image refreshes it, so the application should do that when
it starts:

    mkdir -p ~/.MakeMKV
    cp -n /defaults/settings.conf ~/.MakeMKV/settings.conf
    makemkv-update-beta-key ~/.MakeMKV/settings.conf

or, with a purchased key:

    makemkv-set-key "$KEY" ~/.MakeMKV/settings.conf

## Updating MakeMKV

Bump `MAKEMKV_VERSION` in the `Dockerfile` together with `MAKEMKV_OSS_SHA256` and
`MAKEMKV_BIN_SHA256`; the build fails if the downloaded tarballs do not match.
