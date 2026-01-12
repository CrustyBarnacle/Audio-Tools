# Audio-Tools

Modular toolkit for CD ripping and audio conversion.

## Features

- Automated CD ripping using `abcde` with CDDB metadata lookup
- Handles interactive prompts automatically (CDDB selection, resume sessions)
- Standalone FLAC to MP3 conversion with metadata preservation
- High-quality VBR MP3 encoding (lame -V 0)
- Modular design - use individual tools or the full workflow

## Requirements

Install the following packages:

**Debian/Ubuntu:**
```bash
sudo apt install abcde expect flac lame
```

**Fedora:**
```bash
sudo dnf install abcde expect flac lame
```

**Arch Linux:**
```bash
sudo pacman -S abcde expect flac lame
```

## Usage

### Main Wrapper Script

```bash
./audio-tools.sh <command> [options]
```

| Command | Description |
|---------|-------------|
| `rip [device] [output_dir]` | Rip CD to FLAC |
| `convert [directory]` | Convert FLAC files to MP3 |
| `all [device] [output_dir]` | Rip CD and convert to MP3 |

### Individual Scripts

**Rip CD only:**
```bash
./rip_cd.sh [device] [output_dir]
```

**Convert FLAC to MP3 only:**
```bash
./flac2mp3.sh [directory]
```

### Examples

```bash
# Full workflow: rip CD and convert to MP3
./audio-tools.sh all

# Rip CD only (no conversion)
./audio-tools.sh rip /dev/sr0 ~/Music

# Convert existing FLAC files to MP3
./audio-tools.sh convert ~/Music

# Or use individual scripts directly
./rip_cd.sh /dev/cdrom ~/Music
./flac2mp3.sh ~/Music
```

## How It Works

- **rip_cd.sh**: Runs `abcde` with Expect automation to handle CDDB prompts. Outputs FLAC files in `Artist/Album/` structure.
- **flac2mp3.sh**: Finds FLAC files (up to 3 directories deep), extracts metadata with `metaflac`, converts to MP3 with `lame -V 0`. Skips files where MP3 already exists.
- **audio-tools.sh**: Wrapper that runs either or both tools.

## CDDB Selection

- Single CDDB entry: selected automatically
- Multiple identical entries: first is selected automatically
- Multiple different entries: prompts for user selection
