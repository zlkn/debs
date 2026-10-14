#!/bin/bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"

rm -rf "$REPO"
mkdir -p "$REPO/pool"
rclone copy "r2:$BUCKET/pool" /build/repo/pool

for deb in "$ROOT"/dist/*.deb; do
    name="$(dpkg-deb -f "$deb" Package)"
    dir="$REPO/pool/$COMPONENT/${name:0:1}/$name"
    mkdir -p "$dir"
    if [ -e "$dir/$(basename "$deb")" ]; then
        echo "Already published, keeping remote copy: $(basename "$deb")"
    else
        cp "$deb" "$dir/"
    fi
done

cp "$ROOT/zlkn.gpg" "$REPO/"

docker run --rm \
    -v "$REPO:/repo" -v "$ROOT/signing-key.asc:/signing-key.asc:ro" -w /repo \
    -e SUITE="$SUITE" -e COMPONENT="$COMPONENT" -e ARCH="$ARCH" \
    -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
    debian:forky sh -euc '
        apt-get update -qq
        apt-get install -qq -y --no-install-recommends apt-utils gnupg >/dev/null
        BIN="dists/$SUITE/$COMPONENT/binary-$ARCH"
        mkdir -p "$BIN"
        apt-ftparchive --arch "$ARCH" packages "pool/$COMPONENT" > "$BIN/Packages"
        gzip -9kf "$BIN/Packages"
        apt-ftparchive \
            -o APT::FTPArchive::Release::Origin=zlkn \
            -o APT::FTPArchive::Release::Label=zlkn \
            -o APT::FTPArchive::Release::Suite="$SUITE" \
            -o APT::FTPArchive::Release::Codename="$SUITE" \
            -o APT::FTPArchive::Release::Architectures="$ARCH" \
            -o APT::FTPArchive::Release::Components="$COMPONENT" \
            release "dists/$SUITE" > /tmp/Release
        mv /tmp/Release "dists/$SUITE/Release"
        export GNUPGHOME="$(mktemp -d)"
        gpg --batch --quiet --import /signing-key.asc
        gpg --batch --yes --clearsign -o "dists/$SUITE/InRelease" "dists/$SUITE/Release"
        chown -R "$HOST_UID:$HOST_GID" dists
    '
