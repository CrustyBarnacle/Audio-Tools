#!/bin/bash
#
# rip_cd.sh - Automated CD ripping with abcde
# Usage: ./rip_cd.sh [device] [output_dir]
# Default device: /dev/sr0
# Default output: current directory

set -euo pipefail

DEVICE="${1:-/dev/sr0}"
OUTPUT_DIR="${2:-.}"

# Create a temporary expect script for handling CDDB selection
EXPECT_SCRIPT=$(mktemp)
trap "rm -f '$EXPECT_SCRIPT'" EXIT

cat > "$EXPECT_SCRIPT" << 'EXPECT_EOF'
#!/usr/bin/expect -f

set timeout -1
set device [lindex $argv 0]

log_user 1

spawn abcde -d "$device"

proc check_duplicates {buffer} {
    # Parse CDDB entries from buffer, check if they're essentially duplicates
    set entry_list {}
    foreach line [split $buffer "\n"] {
        # Match lines like: "1) Artist / Album"
        if {[regexp {^\s*([0-9]+)\)\s+(.+)} $line -> num rest]} {
            # Normalize: lowercase and collapse whitespace
            set normalized [string tolower [regsub -all {\s+} $rest " "]]
            lappend entry_list $normalized
        }
    }

    if {[llength $entry_list] <= 1} {
        return 1
    }

    # Compare all entries to first one
    set first [lindex $entry_list 0]
    foreach entry [lrange $entry_list 1 end] {
        if {$entry ne $first} {
            return 0
        }
    }
    return 1
}

expect {
    # Handle resume prompt - append to existing session
    -re {Erase, Append to, or Keep the existing playlist file\? \[e/a/k\]} {
        puts "\n>>> Resuming: appending to existing session"
        send "a\r"
        exp_continue
    }

    # CDDB entries: [0-N] where 0=none, 1-N are actual entries
    -re {Which entry would you like abcde to use[^\[]*\[0-([0-9]+)\]} {
        set max_entry $expect_out(1,string)
        set buffer $expect_out(buffer)
        set num_entries $max_entry

        if {$num_entries == 1 || [check_duplicates $buffer]} {
            puts "\n>>> Auto-selecting entry 1 (single entry or duplicates)"
            send "1\r"
        } else {
            puts "\n>>> Multiple different CDDB entries found ($num_entries total)."
            puts ">>> Please select an entry (1-$max_entry):"
            expect_user -re {([0-9]+)\n}
            send "$expect_out(1,string)\r"
        }
        exp_continue
    }

    # Handle "Edit selected CDDB data" prompt - decline to avoid opening editor
    -re {Edit selected CDDB data \[Y/n\]\?} {
        puts "\n>>> Skipping CDDB edit"
        send "n\r"
        exp_continue
    }

    # Handle other edit prompts - decline
    -re {edit\? \[y/N\]} {
        send "N\r"
        exp_continue
    }

    # Handle confirmation prompts with Y default (accept)
    -re {\[Y/n\]\?} {
        send "\r"
        exp_continue
    }

    # Handle confirmation prompts with n default (accept default)
    -re {\[y/N\]\?} {
        send "\r"
        exp_continue
    }

    eof {
        puts "\n>>> abcde completed"
    }
}

catch wait result
exit [lindex $result 3]
EXPECT_EOF

chmod +x "$EXPECT_SCRIPT"

echo "=========================================="
echo "CD Ripping Script"
echo "Device: $DEVICE"
echo "Output: $OUTPUT_DIR"
echo "=========================================="

# Check if device exists
if [[ ! -e "$DEVICE" ]]; then
    echo "Error: Device $DEVICE not found"
    exit 1
fi

# Check for required tools
for cmd in abcde expect; do
    if ! command -v "$cmd" &>/dev/null; then
        echo "Error: Required command '$cmd' not found"
        exit 1
    fi
done

# Change to output directory
cd "$OUTPUT_DIR"

echo ""
echo ">>> Starting abcde..."
echo ""

# Run abcde with expect wrapper
expect "$EXPECT_SCRIPT" "$DEVICE"
ABCDE_EXIT=$?

if [[ $ABCDE_EXIT -ne 0 ]]; then
    echo "Error: abcde exited with code $ABCDE_EXIT"
    exit $ABCDE_EXIT
fi

echo ""
echo "=========================================="
echo ">>> CD ripping complete!"
echo "=========================================="
