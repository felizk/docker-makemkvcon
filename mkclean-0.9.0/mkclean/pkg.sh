#!/bin/sh

set -e

echo "Generate the source package for mkclean-0.8.1"
rm -rf mkclean-0.8.1
../corec/tools/branch/branch src.br
rm -rf mkclean-0.8.1.tar.bz2
tar cvfj mkclean-0.8.1.tar.bz2 mkclean-0.8.1
