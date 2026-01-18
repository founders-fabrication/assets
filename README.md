# Image Tools for ff-assets

Image resizing and format conversion tooling for the static asset repository.

## Quick Start

```bash
# Generate all variants for a single image
./scripts/image-tools.sh generate assets/logo_flat.png

# Convert to WebP
./scripts/image-tools.sh convert assets/logo_flat.png webp

# Custom resize
./scripts/image-tools.sh resize assets/logo_flat.png 800 600

# Generate specific preset
./scripts/image-tools.sh preset assets/logo_flat.png thumbnail

# Batch process all images
./scripts/image-tools.sh batch
```

## Commands

### resize
Resize an image to specific dimensions (aspect ratio preserved):
```bash
./scripts/image-tools.sh resize <image> <width> <height> [output]
```

Examples:
```bash
./scripts/image-tools.sh resize logo.png 800 600
./scripts/image-tools.sh resize icon.png 128 128 icon_thumb.png
```

### convert
Convert an image to another format:
```bash
./scripts/image-tools.sh convert <image> <format>
```

Supported formats: `png`, `jpg`, `webp`

Examples:
```bash
./scripts/image-tools.sh convert logo.png webp
./scripts/image-tools.sh convert logo.jpg png
```

### generate
Generate all preset variants for an image:
```bash
./scripts/image-tools.sh generate <image>
```

Creates thumbnails, favicons, email signatures, and banners.

### preset
Generate a specific preset:
```bash
./scripts/image-tools.sh preset <image> <preset_name>
```

Available presets:
- `thumbnail`: 32, 64, 128, 256px squares
- `favicon`: 16x16, 32x32, 180x180
- `email`: 320x100, 600x240
- `banner`: 1200x630, 1200x675

Examples:
```bash
./scripts/image-tools.sh preset logo.png thumbnail
./scripts/image-tools.sh preset logo.png favicon
```

### batch
Process all images in `assets/`:
```bash
./scripts/image-tools.sh batch
```

### help
Show all commands:
```bash
./scripts/image-tools.sh help
```

## Presets

### Thumbnail
Sizes: 32x32, 64x64, 128x128, 256x256
Format: PNG

### Favicon
Sizes: 16x16, 32x32, 180x180
Format: PNG

### Email Signature
Sizes: 320x100, 600x240
Format: PNG

### Banner
Sizes: 1200x630 (OG standard), 1200x675 (Twitter)
Format: PNG

## Output Location

Generated files are placed alongside the original images in `assets/`.

Naming convention: `{original_name}_{width}x{height}.{extension}`

Examples:
- `assets/logo_flat_256x256.webp`
- `assets/icon_up_32x32.png`
- `assets/logo_flat_1200x630.png`

## Requirements

- [ffmpeg](https://ffmpeg.org/) must be installed

Check installation:
```bash
which ffmpeg
```

## Batch Generation

Run the interactive batch script:
```bash
./scripts/generate-all.sh
```

This generates all presets for all images in `assets/`.
