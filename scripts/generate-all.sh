#!/bin/bash
# Generate all image variants for all assets in the repository

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "Image Asset Generator"
echo "========================================"
echo ""
echo "This will generate all preset variants for all images in assets/"
echo ""
echo "Generated variants include:"
echo "  - Thumbnails: 32, 64, 128, 256px"
echo "  - Favicons: 16x16, 32x32, 180x180"
echo "  - Email signatures: 320x100, 600x240"
echo "  - Banners: 1200x630, 1200x675"
echo ""
echo "Press Enter to continue or Ctrl+C to cancel..."
read -r

echo ""
"${SCRIPT_DIR}/image-tools.sh" batch

echo ""
echo "========================================"
echo "Generation complete!"
echo "========================================"
echo ""
echo "Generated files are placed alongside originals in assets/"
echo "Example: logo_flat_256x256.webp, logo_flat_32x32.png"
