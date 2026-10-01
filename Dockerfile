#
# makemkvcon Dockerfile
#
# https://github.com/felizk/docker-makemkvcon
#
# Based on https://github.com/jlesage/docker-makemkv
#

# Base image of the final image. Can be overridden to build a variant, e.g.
# mcr.microsoft.com/dotnet/aspnet:10.0-alpine.
ARG BASE_IMAGE=mcr.microsoft.com/dotnet/runtime:10.0-alpine

# Define software versions.
ARG MAKEMKV_VERSION=2.0.0

# Define software download URLs.
ARG MAKEMKV_OSS_URL=https://www.makemkv.com/download/makemkv-oss-${MAKEMKV_VERSION}.tar.gz
ARG MAKEMKV_BIN_URL=https://www.makemkv.com/download/makemkv-bin-${MAKEMKV_VERSION}.tar.gz

# Define software download checksums. Must be updated with MAKEMKV_VERSION.
ARG MAKEMKV_OSS_SHA256=435316b2d219eb48c880526557addd076b5f5e6de5171424c7651f9cac95b161
ARG MAKEMKV_BIN_SHA256=f1265e74875a186efdfbbbec7459a64e969033515e53cbc4d805f0a374f0a124

# Get Dockerfile cross-compilation helpers.
FROM --platform=$BUILDPLATFORM tonistiigi/xx:1.9.0 AS xx

# Build MakeMKV libraries needed by the closed source binary.
FROM --platform=$BUILDPLATFORM debian:12 AS makemkv-bin
ARG TARGETPLATFORM
ARG MAKEMKV_OSS_URL
ARG MAKEMKV_BIN_URL
ARG MAKEMKV_OSS_SHA256
ARG MAKEMKV_BIN_SHA256
COPY --from=xx / /
COPY src/makemkv-bin /build
RUN /build/build.sh "${MAKEMKV_OSS_URL}" "${MAKEMKV_OSS_SHA256}" "${MAKEMKV_BIN_URL}" "${MAKEMKV_BIN_SHA256}"
RUN xx-verify \
    /opt/makemkv/bin/makemkvcon \
    /opt/makemkv/lib/libmakemkv.so.1 \
    /opt/makemkv/lib/libdriveio.so.0 \
    /opt/makemkv/lib/libmmbd.so.0

# Build MakeMKV open source binaries.
FROM --platform=$BUILDPLATFORM alpine:3.24 AS makemkv-oss
ARG TARGETPLATFORM
ARG MAKEMKV_OSS_URL
ARG MAKEMKV_OSS_SHA256
COPY --from=xx / /
COPY src/makemkv-oss /build
RUN /build/build.sh "${MAKEMKV_OSS_URL}" "${MAKEMKV_OSS_SHA256}"
RUN xx-verify \
    /tmp/makemkv-install/usr/bin/mmccextr \
    /tmp/makemkv-install/usr/bin/mmgplsrv

# Build mkclean.
FROM --platform=$BUILDPLATFORM alpine:3.24 AS mkclean
ARG TARGETPLATFORM
COPY --from=xx / /
COPY src/mkclean /build
COPY mkclean-0.9.0 /build
RUN /build/build.sh
RUN xx-verify /tmp/mkclean/mkclean

# Pull base image.
FROM ${BASE_IMAGE}

# Install dependencies.
RUN \
    apk --no-cache add \
        openjdk8-jre-base \
        # For beta key fetching.
        wget \
        sed \
        # For the eject command.
        util-linux-misc \
        mkvtoolnix

# Add files.
COPY rootfs/ /
COPY --from=makemkv-bin /opt/makemkv /opt/makemkv
COPY --from=makemkv-oss /tmp/makemkv-install/usr /opt/makemkv
COPY --from=mkclean /tmp/mkclean /opt/makemkv/bin

# Update the default configuration file with the latest beta key.  This is best
# effort: the key expires regularly, so it should be refreshed at runtime with
# the same script.
RUN /opt/makemkv/bin/makemkv-update-beta-key /defaults/settings.conf || \
    echo "WARNING: Could not fetch the beta key, image built without one."

# Make the MakeMKV binaries and helper scripts available on the PATH.
ENV PATH=/opt/makemkv/bin:$PATH
