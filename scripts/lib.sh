ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO="$ROOT/build/repo"
BUCKET="${BUCKET:-debs}"
SUITE="forky"
COMPONENT="main"
ARCH="amd64"

rclone() {
    docker run --rm --user "$(id -u):$(id -g)" -v "$ROOT/build:/build" \
        -e RCLONE_CONFIG_R2_TYPE=s3 \
        -e RCLONE_CONFIG_R2_PROVIDER=Cloudflare \
        -e RCLONE_CONFIG_R2_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID" \
        -e RCLONE_CONFIG_R2_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY" \
        -e RCLONE_CONFIG_R2_ENDPOINT="https://$CLOUDFLARE_ACCOUNT_ID.r2.cloudflarestorage.com" \
        -e RCLONE_S3_NO_CHECK_BUCKET=true \
        rclone/rclone "$@"
}
