#!/usr/bin/env bash
set -euo pipefail

PUBLIC_URL="https://github.com/flitto/rtt_sdk"
PUBLIC_IDENTITY="rtt_sdk"
GLOBAL_MIRROR_FILE="${HOME}/Library/org.swift.swiftpm/configuration/mirrors.json"

if [[ ! -f "Package.swift" ]]; then
  echo "error: run this script from the public repo root (Package.swift not found)." >&2
  exit 1
fi

echo "Removing mirror for: $PUBLIC_URL"
swift package config unset-mirror --original "$PUBLIC_URL" || true
swift package config unset-mirror --original "$PUBLIC_IDENTITY" || true

echo
if [[ -f "$GLOBAL_MIRROR_FILE" ]]; then
  if rg -n "https://github.com/flitto/rtt_sdk|\"rtt_sdk\"" "$GLOBAL_MIRROR_FILE" >/dev/null 2>&1; then
    rm -f "$GLOBAL_MIRROR_FILE"
    echo "Removed global mirror file:"
    echo "  $GLOBAL_MIRROR_FILE"
  else
    echo "Global mirror file did not contain this repo mapping. Left unchanged:"
    echo "  $GLOBAL_MIRROR_FILE"
  fi
else
  echo "No global mirror file to clean."
fi

LATEST_BACKUP="$(ls -1t "${GLOBAL_MIRROR_FILE}".rtt_sdk_backup_* 2>/dev/null | head -n 1 || true)"
if [[ -n "$LATEST_BACKUP" ]]; then
  echo
  echo "Latest global mirror backup (manual restore if needed):"
  echo "  $LATEST_BACKUP"
fi

echo
echo "Mirror lookup result:"
URL_LOOKUP="$(swift package config get-mirror --original "$PUBLIC_URL" || true)"
IDENTITY_LOOKUP="$(swift package config get-mirror --original "$PUBLIC_IDENTITY" || true)"

if [[ -n "$URL_LOOKUP" || -n "$IDENTITY_LOOKUP" ]]; then
  echo "warning: local mirror still exists." >&2
  [[ -n "$URL_LOOKUP" ]] && echo "  url: $URL_LOOKUP" >&2
  [[ -n "$IDENTITY_LOOKUP" ]] && echo "  identity: $IDENTITY_LOOKUP" >&2
  exit 1
fi

if [[ -f "$GLOBAL_MIRROR_FILE" ]] && rg -n "https://github.com/flitto/rtt_sdk|\"rtt_sdk\"" "$GLOBAL_MIRROR_FILE" >/dev/null 2>&1; then
  echo "warning: global mirror mapping still exists in $GLOBAL_MIRROR_FILE" >&2
  exit 1
fi

echo "No mirror configured for $PUBLIC_URL"
echo "No mirror configured for identity $PUBLIC_IDENTITY"

echo
echo "Done."
