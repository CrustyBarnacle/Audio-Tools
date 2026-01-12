# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Audio-Tools is a Bash-based CD ripping utility that automates audio extraction from CDs and converts to MP3 format. The project consists of a single executable script.

## Running the Tool

```bash
./rip_cd.sh [device] [output_dir]
```

- `device`: CD drive path (default: `/dev/sr0`)
- `output_dir`: Output directory for ripped files (default: current directory)

## System Dependencies

Required external tools (checked at runtime):
- `abcde` - CD ripper with CDDB lookup
- `expect` - Interactive prompt automation
- `flac` - FLAC decoder
- `lame` - MP3 encoder
- `metaflac` - FLAC metadata reader (used implicitly)

## Architecture

The script operates in two phases:

**Phase 1: CD Ripping (lines 12-148)**
- Generates a temporary Expect script to automate `abcde` interactive prompts
- Expect automation handles: CDDB entry selection (auto-selects if single/duplicate entries, prompts user otherwise), resume sessions, edit prompts
- Output: FLAC files with embedded CDDB metadata in `Artist/Album/` directory structure

**Phase 2: FLAC to MP3 Conversion (lines 152-250)**
- Finds FLAC files (prioritizes recently modified within 60 minutes, falls back to all files within 3 directory levels)
- Extracts metadata tags (title, artist, album, track, date, genre) via `metaflac`
- Converts using `flac -cd | lame -V 0` pipeline with metadata preservation
- Skips files where MP3 already exists

## Key Implementation Details

- Uses `set -euo pipefail` for strict error handling
- Temporary Expect script cleaned up via trap on EXIT
- Expect uses `check_duplicates` proc to compare CDDB entries (normalized lowercase comparison)
- MP3 encoding uses VBR quality 0 (highest quality variable bitrate)
