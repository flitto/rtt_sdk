# Release Runbook

This repository is public.

Do not commit private source code, private URLs, keys, tokens, credentials, or internal scripts.

## Repository Roles

- Public repo (this repo): binary, demo, docs.
- Private core repo (internal): SDK source code and internal tests.

## Branch and Tag Rules

- Private core:
  - Branches: `feature/*`, `release/x.y.z`
  - Tags: `core-x.y.z-rcN`, `core-x.y.z`
- Public repo:
  - Branches: `release/x.y.z`
  - Tags: `x.y.z`

## Push Sequence

1. Private push: `feature/*`
2. Private push: `release/x.y.z`
3. Private push: `core-x.y.z-rc1` tag
4. Validate RC artifact in demo (no public push yet)
5. Private push: `core-x.y.z` final tag
6. Public push: `release/x.y.z` branch with updated binary/docs/demo
7. Public merge push: `main`
8. Public push: `x.y.z` tag

## Local Development with URL Mirror (No Push)

Run from this repo root:

```bash
scripts/set-local-core-mirror.sh /absolute/path/to/Live_translation_SDK
```

Build and run the demo for local validation.

After testing:

```bash
scripts/unset-local-core-mirror.sh
```

Mirror settings are local machine configuration. They must not be documented as permanent project config.

## Public Preflight Checklist

Run before opening or merging a public release PR:

```bash
scripts/preflight-public-release.sh origin/main
```

Required checks:
- Changed files are public-safe only.
- No private repo paths or URLs.
- No key/token-like text in diffs.
- Binary and demo app build succeed.

## Commit Message Policy

- English only.
- Clear intent and scope.
- Recommended format: `type(scope): subject`
- Examples:
  - `chore(binary): update LiveTranslationSDK_iOS.xcframework to 0.1.6`
  - `docs(readme): add public integration notes`
  - `fix(demo): recover chat stream after peer close`
