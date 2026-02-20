#!/usr/bin/env bash
set -euo pipefail

RESOLVED_PATH="ios/LT_Demo/LT_Demo.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
BACKUP_PATH="${RESOLVED_PATH}.public-backup"
TEMP_PATH="${RESOLVED_PATH}.tmp-local"

if [[ ! -f "Package.swift" ]]; then
  echo "error: run this script from the public repo root (Package.swift not found)." >&2
  exit 1
fi

if [[ ! -f "$BACKUP_PATH" ]]; then
  echo "error: backup file not found:"
  echo "  $BACKUP_PATH"
  exit 1
fi

cp "$BACKUP_PATH" "$RESOLVED_PATH"
rm -f "$BACKUP_PATH"
rm -f "$TEMP_PATH"

echo "Restored public Package.resolved."
echo "Removed local backup and temp files."
