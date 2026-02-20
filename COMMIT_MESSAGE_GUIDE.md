# Commit Message Guide

Use English only for commit messages in this public repository.

## Format

`type(scope): subject`

## Types

- `feat`: new user-facing behavior
- `fix`: bug fix
- `docs`: documentation changes
- `chore`: maintenance and version updates
- `refactor`: code structure improvements without behavior changes
- `test`: test changes
- `build`: build or packaging changes
- `ci`: CI workflow changes

## Rules

- Use imperative mood (for example, `update`, `add`, `fix`).
- Keep the subject concise and specific.
- Mention target and purpose when possible.
- Do not use vague subjects such as `update`, `fix`, or `changes` alone.

## Good Examples

- `chore(binary): update LiveTranslationSDK_iOS.xcframework to 0.1.6`
- `docs(runbook): define public release push sequence`
- `fix(demo): handle reconnect after chat peer close`
- `build(package): align dependency metadata for release`

## Avoid

- `fix`
- `update files`
- `misc changes`
