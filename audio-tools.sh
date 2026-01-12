#!/bin/bash
#
# audio-tools.sh - CD ripping and audio conversion toolkit
# Usage: ./audio-tools.sh <command> [options]
#
# Commands:
#   rip [device] [output_dir]  - Rip CD to FLAC
#   convert [directory]        - Convert FLAC files to MP3
#   all [device] [output_dir]  - Rip CD and convert to MP3

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

show_usage() {
    cat << EOF
Usage: $(basename "$0") <command> [options]

Commands:
  rip [device] [output_dir]  - Rip CD to FLAC using abcde
                               Default device: /dev/sr0
                               Default output: current directory

  convert [directory]        - Convert FLAC files to MP3
                               Default directory: current directory

  all [device] [output_dir]  - Rip CD and convert to MP3 (full workflow)
                               Default device: /dev/sr0
                               Default output: current directory

Examples:
  $(basename "$0") rip                    # Rip from default device
  $(basename "$0") rip /dev/cdrom ~/Music # Rip from specific device
  $(basename "$0") convert ~/Music        # Convert existing FLAC files
  $(basename "$0") all                    # Full rip and convert workflow
EOF
}

case "${1:-}" in
    rip)
        shift
        exec "$SCRIPT_DIR/rip_cd.sh" "$@"
        ;;
    convert)
        shift
        exec "$SCRIPT_DIR/flac2mp3.sh" "$@"
        ;;
    all)
        shift
        DEVICE="${1:-/dev/sr0}"
        OUTPUT_DIR="${2:-.}"
        "$SCRIPT_DIR/rip_cd.sh" "$DEVICE" "$OUTPUT_DIR"
        "$SCRIPT_DIR/flac2mp3.sh" "$OUTPUT_DIR"
        ;;
    -h|--help|help)
        show_usage
        exit 0
        ;;
    "")
        show_usage
        exit 1
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo ""
        show_usage
        exit 1
        ;;
esac
