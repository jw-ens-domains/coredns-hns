#!/bin/bash
set -e

SRCDIR=`pwd`
BUILDDIR=`pwd`/build

mkdir -p ${BUILDDIR} 2>/dev/null
cd ${BUILDDIR}
echo "Cloning coredns repo..."
git clone https://github.com/coredns/coredns.git

cd coredns
git checkout v1.8.3

echo "Patching plugin config..."
ed plugin.cfg <<EOED
/rewrite:rewrite
a
hns:github.com/harmony-domains/coredns-hns
.
w
q
EOED

# Add our module to coredns.
echo "Patching go modules..."
ed go.mod <<EOED
a
replace github.com/harmony-domains/coredns-hns => ../..
.
/^)
-1
a
	github.com/harmony-domains/coredns-hns v0.0.1
.
w
q
EOED

go get github.com/harmony-domains/coredns-hns@v0.0.1
go get
go mod download

echo "Building..."
make SHELL='sh -x' CGO_ENABLED=1 coredns

cp coredns ${SRCDIR}
chmod -R 755 .git
cd ${SRCDIR}
rm -r ${BUILDDIR}
