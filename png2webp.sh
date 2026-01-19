#!/bin/bash

# PNG to WebP Converter
# Usage: png2webp.sh <input.png> [output.webp] [quality]

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if ! command -v cwebp &> /dev/null; then
    echo -e "${RED}Error: cwebp is not installed.${NC}"
    echo "Install it with: brew install webp"
    exit 1
fi

if [ $# -lt 1 ]; then
    echo -e "${YELLOW}PNG to WebP Converter${NC}"
    echo ""
    echo "Usage: png2webp.sh <input.png> [output.webp] [quality]"
    echo ""
    echo "Arguments:"
    echo "  input.png    - Input PNG file path"
    echo "  output.webp  - Output WebP file path (optional)"
    echo "  quality      - Quality 0-100 (default: 80)"
    echo ""
    echo "Examples:"
    echo "  png2webp.sh image.png"
    echo "  png2webp.sh image.png output.webp"
    echo "  png2webp.sh image.png output.webp 90"
    exit 1
fi

INPUT="$1"

if [ ! -f "$INPUT" ]; then
    echo -e "${RED}Error: Input file '$INPUT' not found.${NC}"
    exit 1
fi

if [ -n "$2" ]; then
    OUTPUT="$2"
else
    OUTPUT="${INPUT%.*}.webp"
fi

QUALITY="${3:-80}"

echo -e "${YELLOW}Converting:${NC} $INPUT"
echo -e "${YELLOW}Output:${NC}     $OUTPUT"
echo -e "${YELLOW}Quality:${NC}    $QUALITY"
echo ""

cwebp -q "$QUALITY" "$INPUT" -o "$OUTPUT"

if [ $? -eq 0 ]; then
    INPUT_SIZE=$(stat -f%z "$INPUT")
    OUTPUT_SIZE=$(stat -f%z "$OUTPUT")
    INPUT_KB=$((INPUT_SIZE / 1024))
    OUTPUT_KB=$((OUTPUT_SIZE / 1024))
    RATIO=$((100 * OUTPUT_SIZE / INPUT_SIZE))

    echo ""
    echo -e "${GREEN}Conversion successful!${NC}"
    echo "Original: ${INPUT_KB} KB -> WebP: ${OUTPUT_KB} KB (${RATIO}%)"
fi
