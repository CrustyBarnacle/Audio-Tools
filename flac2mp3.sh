#!/bin/bash
#
# flac2mp3.sh - Convert FLAC files to MP3 with metadata preservation
# Usage: ./flac2mp3.sh [directory]
# Default directory: current directory

set -euo pipefail

SEARCH_DIR="${1:-.}"

echo "=========================================="
echo "FLAC to MP3 Converter"
echo "Directory: $SEARCH_DIR"
echo "=========================================="

# Check if directory exists
if [[ ! -d "$SEARCH_DIR" ]]; then
    echo "Error: Directory $SEARCH_DIR not found"
    exit 1
fi

# Check for required tools
for cmd in flac lame metaflac; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: Required command '$cmd' not found"
        exit 1
    fi
done

# Change to search directory
cd "$SEARCH_DIR"

echo ""
echo ">>> Converting FLAC files to MP3..."
echo ""

FLAC_COUNT=0
CONVERT_COUNT=0

while IFS= read -r -d '' flac_file; do
    ((FLAC_COUNT++))

    # Generate MP3 filename
    mp3_file="${flac_file%.flac}.mp3"

    if [[ -f "$mp3_file" ]]; then
        echo "Skipping (exists): $mp3_file"
        continue
    fi

    echo "Converting: $(basename "$flac_file")"

    # Extract metadata from FLAC (head -1 handles files with multiple tags of same type)
    TITLE=$(metaflac --show-tag=TITLE "$flac_file" 2>/dev/null | head -1 | sed 's/TITLE=//' || echo "")
    ARTIST=$(metaflac --show-tag=ARTIST "$flac_file" 2>/dev/null | head -1 | sed 's/ARTIST=//' || echo "")
    ALBUM=$(metaflac --show-tag=ALBUM "$flac_file" 2>/dev/null | head -1 | sed 's/ALBUM=//' || echo "")
    TRACKNUMBER=$(metaflac --show-tag=TRACKNUMBER "$flac_file" 2>/dev/null | head -1 | sed 's/TRACKNUMBER=//' || echo "")
    DATE=$(metaflac --show-tag=DATE "$flac_file" 2>/dev/null | head -1 | sed 's/DATE=//' || echo "")
    GENRE=$(metaflac --show-tag=GENRE "$flac_file" 2>/dev/null | head -1 | sed 's/GENRE=//' || echo "")

    # Build lame arguments (VBR quality 0 = highest quality)
    LAME_ARGS=(-V 0 --quiet)

    [[ -n "$TITLE" ]] && LAME_ARGS+=(--tt "$TITLE")
    [[ -n "$ARTIST" ]] && LAME_ARGS+=(--ta "$ARTIST")
    [[ -n "$ALBUM" ]] && LAME_ARGS+=(--tl "$ALBUM")
    [[ -n "$TRACKNUMBER" ]] && LAME_ARGS+=(--tn "$TRACKNUMBER")
    [[ -n "$DATE" ]] && LAME_ARGS+=(--ty "$DATE")
    [[ -n "$GENRE" ]] && LAME_ARGS+=(--tg "$GENRE")

    # Convert FLAC to MP3 (write to temp file first to avoid partial files on failure)
    mp3_temp="${mp3_file}.tmp"
    if flac -cd "$flac_file" | lame "${LAME_ARGS[@]}" - "$mp3_temp" && [[ -f "$mp3_temp" ]]; then
        mv "$mp3_temp" "$mp3_file"
        ((CONVERT_COUNT++))
        echo "  -> Created: $(basename "$mp3_file")"
    else
        rm -f "$mp3_temp"
        echo "  -> Error converting: $(basename "$flac_file")"
    fi

done < <(find . -maxdepth 3 -name "*.flac" -print0)

echo ""
echo "=========================================="
echo ">>> Complete!"
echo "    FLAC files found: $FLAC_COUNT"
echo "    MP3 files created: $CONVERT_COUNT"
echo "=========================================="
