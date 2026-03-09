#!/usr/bin/env bash
set -euo pipefail

BASE_REF="${1:-origin/main}"

if [[ ! -d ".git" ]]; then
  echo "error: run this script from the public repo root (.git not found)." >&2
  exit 1
fi

if ! git rev-parse --verify "$BASE_REF" >/dev/null 2>&1; then
  echo "error: base ref not found: $BASE_REF" >&2
  exit 1
fi

CHANGED_FILES=()

append_unique_file() {
  local candidate="$1"
  local existing
  for existing in "${CHANGED_FILES[@]-}"; do
    if [[ "$existing" == "$candidate" ]]; then
      return 0
    fi
  done
  CHANGED_FILES+=("$candidate")
}

while IFS= read -r file; do
  [[ -n "$file" ]] && append_unique_file "$file"
done < <(git diff --name-only "$BASE_REF"...HEAD)

while IFS= read -r file; do
  [[ -n "$file" ]] && append_unique_file "$file"
done < <(git diff --name-only)

while IFS= read -r file; do
  [[ -n "$file" ]] && append_unique_file "$file"
done < <(git diff --name-only --cached)

if [[ ${#CHANGED_FILES[@]} -eq 0 ]]; then
  echo "No changed files between $BASE_REF and HEAD."
  exit 0
fi

ALLOWED_PATTERNS=(
  '^ios/binary/LiveTranslationSDK\.xcframework/'
  '^ios/LT_Demo/'
  '^Package\.swift$'
  '^README\.md$'
  '^RELEASE_RUNBOOK\.md$'
  '^COMMIT_MESSAGE_GUIDE\.md$'
  '^scripts/set-local-core-mirror\.sh$'
  '^scripts/unset-local-core-mirror\.sh$'
  '^scripts/preflight-public-release\.sh$'
  '^scripts/resolve-demo-local-packages\.sh$'
  '^scripts/restore-demo-public-resolved\.sh$'
  '^\.gitignore$'
)

VIOLATIONS=()
for file in "${CHANGED_FILES[@]}"; do
  MATCHED=0
  for pattern in "${ALLOWED_PATTERNS[@]}"; do
    if [[ "$file" =~ $pattern ]]; then
      MATCHED=1
      break
    fi
  done
  if [[ $MATCHED -eq 0 ]]; then
    VIOLATIONS+=("$file")
  fi
done

if [[ ${#VIOLATIONS[@]} -gt 0 ]]; then
  echo "error: non-public-safe files detected:"
  for file in "${VIOLATIONS[@]}"; do
    echo "  - $file"
  done
  exit 1
fi

DANGER_REGEX='interactord/Live_translation_SDK|file:///Users/|BEGIN RSA PRIVATE KEY|BEGIN OPENSSH PRIVATE KEY|AKIA[0-9A-Z]{16}|SECRET|TOKEN|PASSWORD'

TMP_FILE="$(mktemp)"
DIFF_INPUT_FILE="$(mktemp)"
{ git diff "$BASE_REF"...HEAD; git diff; git diff --cached; } | grep -Ev '^[ +-]DANGER_REGEX=' >"$DIFF_INPUT_FILE"

if command -v rg >/dev/null 2>&1; then
  if rg -n --pcre2 "$DANGER_REGEX" "$DIFF_INPUT_FILE" >"$TMP_FILE"; then
    echo "error: suspicious content found in diff:"
    cat "$TMP_FILE"
    rm -f "$DIFF_INPUT_FILE"
    rm -f "$TMP_FILE"
    exit 1
  fi
else
  if grep -nE "$DANGER_REGEX" "$DIFF_INPUT_FILE" >"$TMP_FILE"; then
    echo "error: suspicious content found in diff:"
    cat "$TMP_FILE"
    rm -f "$DIFF_INPUT_FILE"
    rm -f "$TMP_FILE"
    exit 1
  fi
fi

rm -f "$DIFF_INPUT_FILE"
rm -f "$TMP_FILE"

echo "Preflight passed:"
echo "  - changed files are within allowed public scope"
echo "  - no suspicious private text detected in diff"
