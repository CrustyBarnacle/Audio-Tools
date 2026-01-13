# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Audio-Tools is a Bash-based toolkit for CD ripping and audio conversion. The project uses a modular design with three scripts.

## Scripts

| Script | Purpose | Dependencies |
|--------|---------|--------------|
| `audio-tools.sh` | Main wrapper with subcommands | - |
| `rip_cd.sh` | CD ripping via abcde | `abcde`, `expect` |
| `flac2mp3.sh` | FLAC to MP3 conversion | `flac`, `lame`, `metaflac` |

## Usage

```bash
# Wrapper script
./audio-tools.sh rip [device] [output_dir]
./audio-tools.sh convert [directory]
./audio-tools.sh all [device] [output_dir]

# Individual scripts
./rip_cd.sh [device] [output_dir]
./flac2mp3.sh [directory]
```

## Architecture

### rip_cd.sh
- Generates temporary Expect script to automate `abcde` interactive prompts
- Expect `check_duplicates` proc compares CDDB entries (normalized lowercase)
- Auto-selects single/duplicate CDDB entries, prompts user for different entries
- Output: FLAC files in `Artist/Album/` structure

### flac2mp3.sh
- Finds all FLAC files within 3 directory levels
- Extracts metadata (title, artist, album, track, date, genre) via `metaflac`
- Converts using `flac -cd | lame -V 0` pipeline
- Skips files where MP3 already exists

### audio-tools.sh
- Subcommand wrapper using `exec` for `rip` and `convert`
- `all` command runs both scripts sequentially

## Key Implementation Details

- All scripts use `set -euo pipefail` for strict error handling
- Temporary Expect script cleaned up via trap on EXIT
- MP3 encoding uses VBR quality 0 (highest quality)

## Development Workflow

### Code Reviews
When asked to review code, analyze for:
- **Code duplication** - repeated patterns that could be consolidated
- **Logic bugs** - edge cases, silent failures, incorrect handling
- **Security issues** - command injection, unquoted variables, unsafe patterns

Categorize findings by severity (high/medium/low) in a summary table.

### Branching and Commits
- Create feature/fix branches from `main` (e.g., `fix/medium-severity-issues`)
- Make separate commits for each distinct fix
- Use descriptive commit messages explaining the "why"
- Merge to `main` with `--no-ff` to preserve branch history

### Testing
- Run smoke tests before finalizing changes: `./tests/smoke_test.sh`
- All tests must pass before merging to main

### Release Process
1. Ensure all fixes are merged to `main`
2. Sync `dev` branch: pull remote dev, merge main, push
3. Run smoke tests on `dev`
4. Create annotated tag: `git tag -a vX.Y.Z -m "message"`
5. Push tag: `git push origin vX.Y.Z`
6. Create GitHub release: `gh release create vX.Y.Z --title "..." --notes "..."`

### Version Numbering
- **Major (X)**: Breaking changes
- **Minor (Y)**: New features, security fixes
- **Patch (Z)**: Bug fixes
