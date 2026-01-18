# Configuration Reference

This document describes configuration options for the image processing tools.

## Environment Variables

No environment variables are required. All options are passed as command-line arguments.

## Preset Definitions

The tool includes built-in presets. Each preset defines sizes and formats:

### thumbnail
```bash
sizes=(32 64 128 256)
format="png"
```

### favicon
```bash
sizes=("16x16" "32x32" "180x180")
format="png"
```

### email
```bash
sizes=(320x100 600x240)
format="png"
```

### banner
```bash
sizes=(1200x630 1200x675)
format="png"
```

## Customization

To modify presets, edit `scripts/image-tools.sh`:

1. Find the relevant function:
   - `generate_thumbnails()` - lines ~90
   - `generate_favicon()` - lines ~98
   - `generate_email()` - lines ~106
   - `generate_banner()` - lines ~110

2. Modify the `sizes` array or dimensions

3. Save and run again

Example - Add 512px thumbnail:
```bash
generate_thumbnails() {
    local input="$1"
    local sizes=(32 64 128 256 512)  # Added 512

    for size in "${sizes[@]}"; do
        resize_image "$input" "$size" "$size"
    done
}
```

## Output Directory

Default output: `assets/` (same directory as source)

To change output location, modify the `ASSETS_DIR` variable at the top of `image-tools.sh`:

```bash
ASSETS_DIR="${SCRIPT_DIR}/../assets"  # Current: assets/
```

## File Overwrite Behavior

When a generated file already exists, the script prompts:
```
File exists: logo_flat_256x256.webp. Overwrite? (y/n/a):
```

Options:
- `y` - Overwrite this file
- `n` - Skip this file
- `a` - Overwrite all subsequent files

## Supported Formats

Input:
- PNG, JPG, JPEG, WebP

Output:
- PNG, JPG, WebP

SVGs are accepted as input but not modified (they are scalable by nature).

## Image Processing

### Resize Algorithm
1. Scale to fit within target dimensions
2. Preserve aspect ratio
3. Pad with transparent pixels if needed

### Format Conversion
- **To WebP**: ffmpeg libwebp codec, quality 85
- **To PNG**: Lossless compression
- **To JPG**: Quality level 2 (high quality)

## Performance Notes

- Processing is sequential (not parallel)
- Large images take longer to process
- SVG files are skipped automatically
- Check `ffmpeg` is in your PATH before running
