#!/bin/bash
set -euo pipefail

UID_STR="${KEY_UID:-zlkn apt repository <zolkin.u.a@gmail.com>}"
EXPIRE="${KEY_EXPIRE:-2y}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

fpr() {
    { gpg --list-secret-keys --with-colons "=$UID_STR" 2>/dev/null || true; } | awk -F: '/^fpr/ {print $10; exit}'
}

FPR="$(fpr)"
if [ -z "$FPR" ]; then
    gpg --batch --passphrase '' --quick-gen-key "$UID_STR" ed25519 sign "$EXPIRE"
    FPR="$(fpr)"
fi
echo "Key: $FPR"

umask 077
gpg --armor --export-secret-keys "$FPR" > "$ROOT/signing-key.asc"
gpg --export "$FPR" > "$ROOT/zlkn.gpg"
chmod 644 "$ROOT/zlkn.gpg"
