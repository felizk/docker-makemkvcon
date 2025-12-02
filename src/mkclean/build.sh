#!/bin/sh

set -e # Exit immediately if a command exits with a non-zero status.
set -u # Treat unset variables as an error.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

export CFLAGS="-Os -fomit-frame-pointer -DQT_NO_DEBUG_OUTPUT"
export CXXFLAGS="$CFLAGS"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,--strip-all -Wl,--as-needed"

export CC=xx-clang
export CXX=xx-clang++

function log {
    echo ">>> $*"
}

apk --no-cache add \
    clang \
    llvm13 \
    make \
    cmake \

xx-apk --no-cache --no-scripts add \
    musl-dev \
    gcc \
    g++ \

cd build
mkdir build
gcc corec/tools/coremake/coremake.c -o coremake
./coremake gcc_linux_x64
cd build
#cmake ..
make -C mkclean

mkdir /tmp/mkclean
cp -v /build/build/mkclean/mkclean /tmp/mkclean/
