#!/usr/bin/env bash
set -euo pipefail

PUBLIC_URL="https://github.com/flitto/rtt_sdk"

if [[ ! -f "Package.swift" ]]; then
  echo "error: run this script from the public repo root (Package.swift not found)." >&2
  exit 1
fi

if [[ $# -ne 1 ]]; then
  echo "usage: $0 /absolute/path/to/Live_translation_SDK" >&2
  exit 1
fi

CORE_PATH_INPUT="$1"
if [[ ! -d "$CORE_PATH_INPUT" ]]; then
  echo "error: path does not exist: $CORE_PATH_INPUT" >&2
  exit 1
fi

CORE_PATH="$(cd "$CORE_PATH_INPUT" && pwd)"
if [[ ! -f "$CORE_PATH/Package.swift" ]]; then
  echo "error: Package.swift not found in: $CORE_PATH" >&2
  exit 1
fi

MIRROR_URL="file://$CORE_PATH"

echo "Setting mirror:"
echo "  original: $PUBLIC_URL"
echo "  mirror:   $MIRROR_URL"

swift package config set-mirror --original "$PUBLIC_URL" --mirror "$MIRROR_URL"

echo
echo "Current mirror:"
swift package config get-mirror --original "$PUBLIC_URL"

echo
echo "Done. Resolve packages in Xcode if needed."
