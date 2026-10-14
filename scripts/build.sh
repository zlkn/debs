#!/bin/bash
set -euo pipefail

PKG="$1"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PKG_DIR="$ROOT/packages/$PKG"
BUILD="$ROOT/build/$PKG"
DIST="$ROOT/dist"
IMAGE="${IMAGE:-debian:forky}"

read -r SHA URL < "$PKG_DIR/source"
TARBALL="$ROOT/build/cache/$(basename "$URL")"

mkdir -p "$(dirname "$TARBALL")" "$DIST"
[ -f "$TARBALL" ] || curl -fsSL -o "$TARBALL" "$URL"
echo "$SHA  $TARBALL" | sha256sum -c -

rm -rf "$BUILD"
mkdir -p "$BUILD/src"
tar xzf "$TARBALL" -C "$BUILD/src"
cp -a "$PKG_DIR/debian" "$BUILD/src/"

docker run --rm \
    -v "$BUILD/src:/src:ro" -v "$DIST:/dist" \
    -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
    "$IMAGE" sh -euc '
        apt-get update -qq
        apt-get install -qq -y --no-install-recommends build-essential debhelper lintian >/dev/null
        mkdir /work && cp -a /src /work/src && cd /work/src
        dpkg-buildpackage -b -us -uc
        lintian --fail-on error,warning ../*.deb
        cp ../*.deb /dist/
        chown "$HOST_UID:$HOST_GID" /dist/*.deb
    '
