#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="ios/LT_Demo/LT_Demo.xcodeproj"
SCHEME_NAME="LT_Demo"
RESOLVED_PATH="ios/LT_Demo/LT_Demo.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"
BACKUP_PATH="${RESOLVED_PATH}.public-backup"
TEMP_PATH="${RESOLVED_PATH}.tmp-local"
SPM_CLONES_DIR="/tmp/rtt_sdk_sourcepackages_local_$(date +%s)"

if [[ ! -f "Package.swift" ]]; then
  echo "error: run this script from the public repo root (Package.swift not found)." >&2
  exit 1
fi

if [[ ! -f "$PROJECT_PATH/project.pbxproj" ]]; then
  echo "error: demo project not found at $PROJECT_PATH" >&2
  exit 1
fi

if [[ -f "$BACKUP_PATH" ]]; then
  echo "backup already exists:"
  echo "  $BACKUP_PATH"
  echo "If this is stale, restore first with:"
  echo "  scripts/restore-demo-public-resolved.sh"
  exit 1
fi

if [[ ! -f "$RESOLVED_PATH" ]]; then
  echo "error: expected resolved file not found: $RESOLVED_PATH" >&2
  exit 1
fi

cp "$RESOLVED_PATH" "$BACKUP_PATH"
mv "$RESOLVED_PATH" "$TEMP_PATH"

restore_on_error() {
  if [[ -f "$TEMP_PATH" ]]; then
    mv "$TEMP_PATH" "$RESOLVED_PATH"
  fi
  if [[ -f "$BACKUP_PATH" ]]; then
    rm -f "$BACKUP_PATH"
  fi
}

if ! xcodebuild -resolvePackageDependencies \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME_NAME" \
  -clonedSourcePackagesDirPath "$SPM_CLONES_DIR"; then
  echo
  echo "error: failed to resolve local packages. Restoring original Package.resolved."
  restore_on_error
  exit 1
fi

if [[ -f "$TEMP_PATH" ]]; then
  rm -f "$TEMP_PATH"
fi

if [[ ! -f "$RESOLVED_PATH" ]]; then
  echo "error: xcodebuild finished but no resolved file was generated." >&2
  restore_on_error
  exit 1
fi

echo
echo "Local package resolution completed."
echo "Backup saved:"
echo "  $BACKUP_PATH"
echo
echo "Before commit, restore public lockfile:"
echo "  scripts/restore-demo-public-resolved.sh"
