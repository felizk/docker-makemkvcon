#!/bin/sh

#
# This script builds the MakeMKV open source helper binaries (mmccextr and
# mmgplsrv).
#
# NOTE: The MakeMKV configure script also checks dependencies of the libraries.
#       Thus, we need to satisfy dependencies that are not needed by these
#       binaries (e.g. ffmpeg).
#

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Set same default compilation flags as abuild.
export CFLAGS="-Os -fomit-frame-pointer"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--strip-all -Wl,--as-needed"

export CC=xx-clang
export CXX=xx-clang++

function log {
    echo ">>> $*"
}

MAKEMKV_URL="$1"
MAKEMKV_SHA256="$2"

if [ -z "$MAKEMKV_URL" ]; then
    log "ERROR: MakeMKV URL missing."
    exit 1
fi

if [ -z "$MAKEMKV_SHA256" ]; then
    log "ERROR: MakeMKV checksum missing."
    exit 1
fi

#
# Install required packages.
#
apk --no-cache add \
    curl \
    clang \
    llvm \
    make \
    patch \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \
    openssl-dev \
    expat-dev \
    zlib-dev \
    ffmpeg-dev \

#
# Download sources.
#

log "Downloading MakeMKV..."
mkdir /tmp/makemkv
curl -# -L -f -o /tmp/makemkv.tar.gz "${MAKEMKV_URL}"
echo "${MAKEMKV_SHA256}  /tmp/makemkv.tar.gz" | sha256sum -c -
tar xzf /tmp/makemkv.tar.gz --strip 1 -C /tmp/makemkv

#
# Compile MakeMKV.
#

MAKEMKV_COMPILED_BINS="\
    out/mmccextr \
    out/mmgplsrv \
"

log "Patching MakeMKV..."
patch -d /tmp/makemkv -p1 < "$SCRIPT_DIR/fix-include.patch"

log "Configuring MakeMKV..."
(
    cd /tmp/makemkv && OBJCOPY=llvm-objcopy ./configure \
        --build=$(TARGETPLATFORM= xx-clang --print-target-triple) \
        --host=$(xx-clang --print-target-triple) \
        --prefix=/usr \
        --disable-gui \
)

# FFmpeg was installed only to satisfy the configure part.  The binaries built
# here are not using it.
xx-apk --no-cache --no-scripts del ffmpeg-dev

log "Compiling MakeMKV..."
make -C /tmp/makemkv -j$(nproc) $MAKEMKV_COMPILED_BINS

log "Installing MakeMKV..."
mkdir -p /tmp/makemkv-install/usr/bin
for BIN in $MAKEMKV_COMPILED_BINS
do
    cp -v /tmp/makemkv/"$BIN" /tmp/makemkv-install/usr/bin/
done

# vim:ft=sh:ts=4:sw=4:et:sts=4
