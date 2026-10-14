#!/bin/bash
set -euo pipefail
. "$(dirname "$0")/lib.sh"

rclone copy --immutable /build/repo/pool "r2:$BUCKET/pool"
rclone copyto /build/repo/zlkn.gpg "r2:$BUCKET/zlkn.gpg"
rclone sync /build/repo/dists "r2:$BUCKET/dists"
