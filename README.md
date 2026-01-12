# Audio-Tools

Automated CD ripping with CDDB lookup and MP3 conversion.

## Features

- Automated CD ripping using `abcde` with CDDB metadata lookup
- Handles interactive prompts automatically (CDDB selection, resume sessions)
- Converts ripped FLAC files to high-quality VBR MP3
- Preserves metadata tags (title, artist, album, track number, date, genre)
- Skips conversion if MP3 already exists

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

```bash
./rip_cd.sh [device] [output_dir]
```

| Argument | Default | Description |
|----------|---------|-------------|
| `device` | `/dev/sr0` | CD drive device path |
| `output_dir` | `.` | Directory for output files |

### Examples

```bash
# Rip from default device to current directory
./rip_cd.sh

# Rip from specific device
./rip_cd.sh /dev/cdrom

# Rip to specific output directory
./rip_cd.sh /dev/sr0 ~/Music
```

## How It Works

1. **Ripping**: Runs `abcde` to rip the CD to FLAC format, automatically handling CDDB entry selection and other prompts
2. **Conversion**: Finds the ripped FLAC files and converts them to MP3 using `lame -V 0` (highest quality VBR) while preserving all metadata tags

Output is organized in `Artist/Album/` directory structure by `abcde`.

## CDDB Selection

- If only one CDDB entry exists, it's selected automatically
- If multiple identical entries exist, the first is selected automatically
- If multiple different entries exist, you'll be prompted to choose
