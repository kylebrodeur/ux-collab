#!/usr/bin/env bash
# optimize-screenshot.sh
# Resize and compress the latest Playwright screenshot for use in chat.
# Usage:
#   ./optimize-screenshot.sh                     → optimizes latest screenshot
#   ./optimize-screenshot.sh /path/to/file.png   → optimizes a specific file
#
# Output: prints the path of the optimized file to stdout

set -euo pipefail

PLAYWRIGHT_DIR="/tmp/playwright-mcp-output"
OPTIMIZED_DIR="/tmp/playwright-screenshots-optimized"
MAX_WIDTH=1280
JPEG_QUALITY=82

mkdir -p "$OPTIMIZED_DIR"

# Resolve input file
if [[ $# -ge 1 && -f "$1" ]]; then
  INPUT="$1"
else
  # Find the most recently modified PNG across all session subdirs
  INPUT=$(find "$PLAYWRIGHT_DIR" -name "*.png" -printf "%T@ %p\n" 2>/dev/null \
    | sort -n | tail -1 | cut -d' ' -f2-)
fi

if [[ -z "$INPUT" ]]; then
  echo "ERROR: No screenshots found in $PLAYWRIGHT_DIR" >&2
  exit 1
fi

BASENAME=$(basename "$INPUT" .png)
OUTPUT="$OPTIMIZED_DIR/${BASENAME}-opt.jpg"

# Get original dimensions and size
ORIG_SIZE=$(du -h "$INPUT" | cut -f1)
ORIG_DIMS=$(identify -format "%wx%h" "$INPUT" 2>/dev/null || echo "unknown")

# Convert: resize to max width, strip metadata, JPEG at target quality
convert "$INPUT" \
  -resize "${MAX_WIDTH}x>" \
  -strip \
  -quality "$JPEG_QUALITY" \
  "$OUTPUT"

OPT_SIZE=$(du -h "$OUTPUT" | cut -f1)
OPT_DIMS=$(identify -format "%wx%h" "$OUTPUT" 2>/dev/null || echo "unknown")

echo "$OUTPUT"
echo "  original: $ORIG_DIMS @ $ORIG_SIZE  →  optimized: $OPT_DIMS @ $OPT_SIZE" >&2
