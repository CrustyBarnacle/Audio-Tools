# Contributing to Audio-Tools

## Getting Started

1. Clone the repository
2. Ensure dependencies are installed:
   - `abcde`, `expect` (for CD ripping)
   - `flac`, `lame`, `metaflac` (for conversion)

## Branch Strategy

| Branch | Purpose |
|--------|---------|
| `main` | Stable release branch |
| `dev` | Integration branch with CI/smoke tests |
| `feature/*` | New features |
| `fix/*` | Bug fixes and security patches |

### Workflow

1. Create a branch from `main`:
   ```bash
   git checkout main
   git checkout -b fix/description-of-fix
   ```

2. Make changes with atomic commits (one fix per commit)

3. Merge to `main`:
   ```bash
   git checkout main
   git merge --no-ff fix/description-of-fix
   ```

4. Sync `dev` with `main`:
   ```bash
   git checkout dev
   git pull origin dev
   git merge main
   git push origin dev
   ```

## Testing

Smoke tests are located on the `dev` branch. After syncing `main` to `dev`, run:

```bash
git checkout dev
./tests/smoke_test.sh
```

All tests must pass before creating a release.

## Code Standards

- All scripts use `set -euo pipefail` for strict error handling
- Quote all variables to prevent word splitting
- Use `[[ ]]` for conditionals (bash-specific, safer)
- Clean up temporary files via `trap ... EXIT`

## Releases

Releases follow [Semantic Versioning](https://semver.org/):

- **Major (X.0.0)**: Breaking changes
- **Minor (X.Y.0)**: New features, security fixes
- **Patch (X.Y.Z)**: Bug fixes

### Release Process

1. Ensure `main` has all changes
2. Sync and test on `dev`
3. Tag the release:
   ```bash
   git tag -a vX.Y.Z -m "vX.Y.Z - Release title"
   git push origin vX.Y.Z
   ```
4. Create GitHub release:
   ```bash
   gh release create vX.Y.Z --title "vX.Y.Z - Title" --notes "Release notes..."
   ```

## Security

When reviewing or writing code, watch for:

- Unquoted variables in shell commands
- Command injection via user input
- Unsafe temporary file handling
- Silent error suppression that hides failures

Report security issues by opening an issue or contacting the maintainer directly.
