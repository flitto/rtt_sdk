#!/usr/bin/env bash
set -euo pipefail

PUBLIC_URL="https://github.com/flitto/rtt_sdk"
PUBLIC_IDENTITY="rtt_sdk"
MIN_REQUIRED_TAG="0.1.1"
GLOBAL_MIRROR_DIR="${HOME}/Library/org.swift.swiftpm/configuration"
GLOBAL_MIRROR_FILE="${GLOBAL_MIRROR_DIR}/mirrors.json"

if [[ ! -f "Package.swift" ]]; then
  echo "error: run this script from the public repo root (Package.swift not found)." >&2
  exit 1
fi

CREATE_LOCAL_TAG=0
if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "usage: $0 /absolute/path/to/Live_translation_SDK [--create-local-tag]" >&2
  echo "note: --create-local-tag creates local tag ${MIN_REQUIRED_TAG} in the core repo when missing." >&2
  exit 1
fi

CORE_PATH_INPUT="$1"
if [[ $# -eq 2 ]]; then
  if [[ "$2" == "--create-local-tag" ]]; then
    CREATE_LOCAL_TAG=1
  else
    echo "error: unknown option: $2" >&2
    exit 1
  fi
fi

if [[ ! -d "$CORE_PATH_INPUT" ]]; then
  echo "error: path does not exist: $CORE_PATH_INPUT" >&2
  exit 1
fi

CORE_PATH="$(cd "$CORE_PATH_INPUT" && pwd)"
if [[ ! -f "$CORE_PATH/Package.swift" ]]; then
  echo "error: Package.swift not found in: $CORE_PATH" >&2
  exit 1
fi

if ! git -C "$CORE_PATH" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "error: core path is not a git repository: $CORE_PATH" >&2
  exit 1
fi

if ! git -C "$CORE_PATH" ls-files --error-unmatch Package.swift >/dev/null 2>&1; then
  echo "error: Package.swift exists but is not tracked in git." >&2
  echo "       Commit it in the core repo before using mirror mode." >&2
  exit 1
fi

if ! git -C "$CORE_PATH" rev-parse -q --verify "refs/tags/${MIN_REQUIRED_TAG}" >/dev/null 2>&1; then
  if [[ $CREATE_LOCAL_TAG -eq 1 ]]; then
    git -C "$CORE_PATH" tag "$MIN_REQUIRED_TAG"
    echo "Created local tag in core repo: ${MIN_REQUIRED_TAG}"
  else
    echo "error: required local tag '${MIN_REQUIRED_TAG}' not found in core repo." >&2
    echo "       The demo package currently resolves with version range >= ${MIN_REQUIRED_TAG}." >&2
    echo "       Re-run with --create-local-tag or create the tag manually." >&2
    exit 1
  fi
fi

MIRROR_URL="file://$CORE_PATH"

echo "Setting local mirror:"
echo "  original: $PUBLIC_URL"
echo "  mirror:   $MIRROR_URL"

swift package config set-mirror --original "$PUBLIC_URL" --mirror "$MIRROR_URL"
swift package config set-mirror --original "$PUBLIC_IDENTITY" --mirror "$MIRROR_URL"

mkdir -p "$GLOBAL_MIRROR_DIR"
if [[ -f "$GLOBAL_MIRROR_FILE" ]]; then
  BACKUP_FILE="${GLOBAL_MIRROR_FILE}.rtt_sdk_backup_$(date +%Y%m%d_%H%M%S)"
  cp "$GLOBAL_MIRROR_FILE" "$BACKUP_FILE"
  echo "Backed up global mirrors file:"
  echo "  $BACKUP_FILE"
fi

cat > "$GLOBAL_MIRROR_FILE" <<JSON
{
  "object" : [
    {
      "mirror" : "$MIRROR_URL",
      "original" : "$PUBLIC_URL"
    },
    {
      "mirror" : "$MIRROR_URL",
      "original" : "$PUBLIC_IDENTITY"
    }
  ],
  "version" : 1
}
JSON

echo
echo "Current local mirror:"
swift package config get-mirror --original "$PUBLIC_URL"
echo "Current local identity mirror:"
swift package config get-mirror --original "$PUBLIC_IDENTITY"

echo
echo "Current global mirror file:"
cat "$GLOBAL_MIRROR_FILE"

echo
echo "Done."
echo "Next step:"
echo "  scripts/resolve-demo-local-packages.sh"
