#!/usr/bin/env bash
set -euo pipefail

PUBLIC_URL="https://github.com/flitto/rtt_sdk"

if [[ ! -f "Package.swift" ]]; then
  echo "error: run this script from the public repo root (Package.swift not found)." >&2
  exit 1
fi

echo "Removing mirror for: $PUBLIC_URL"
swift package config unset-mirror --original "$PUBLIC_URL" || true

echo
echo "Mirror lookup result:"
if swift package config get-mirror --original "$PUBLIC_URL"; then
  echo "warning: mirror still exists. Check local SwiftPM configuration." >&2
  exit 1
else
  echo "No mirror configured for $PUBLIC_URL"
fi

echo
echo "Done."
