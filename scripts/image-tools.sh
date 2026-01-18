#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ASSETS_DIR="${SCRIPT_DIR}/../assets"
OUTPUT_DIR="${SCRIPT_DIR}/../generated"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

supported_formats() { echo "png jpg jpeg webp svg"; }
is_supported_format() {
    local fmt="$1"
    local supported=$(supported_formats)
    for f in $supported; do
        [[ "$fmt" == "$f" ]] && return 0
    done
    return 1
}

get_image_info() {
    local img="$1"
    ffmpeg -v error -i "$img" -f null - 2>&1 | grep -E "Stream.*Video" | head -1 || true
}

get_base_name() {
    local img="$1"
    basename "$img" | sed 's/\.[^.]*$//'
}

get_extension() {
    local img="$1"
    echo "$img" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]'
}

prompt_overwrite() {
    local file="$1"
    read -p "File exists: $file. Overwrite? (y/n/a): " answer
    case "$answer" in
        y|Y) return 0 ;;
        a|A) OVERWRITE_ALL=true; return 0 ;;
        *) return 1 ;;
    esac
}

should_overwrite() {
    local file="$1"
    if [[ "$OVERWRITE_ALL" == "true" ]]; then
        return 0
    fi
    if [[ -f "$file" ]]; then
        prompt_overwrite "$file"
    else
        return 0
    fi
}

resize_image() {
    local input="$1"
    local width="$2"
    local height="$3"
    local output="${4:-}"

    if [[ ! -f "$input" ]]; then
        log_error "Input file not found: $input"
        return 1
    fi

    if ! is_supported_format "$(get_extension "$input")"; then
        log_error "Unsupported format: $(get_extension "$input")"
        return 1
    fi

    local base_name
    base_name=$(get_base_name "$input")
    local ext
    ext=$(get_extension "$input")

    if [[ -z "$output" ]]; then
        output="${ASSETS_DIR}/${base_name}_${width}x${height}.${ext}"
    fi

    if ! should_overwrite "$output"; then
        log_info "Skipped: $output"
        return 0
    fi

    log_info "Resizing $input -> $output (${width}x${height})"

    ffmpeg -y -v error -i "$input" \
        -vf "scale=${width}:${height}:force_original_aspect_ratio=decrease,pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2:color=00000000" \
        -c:v png \
        "$output" 2>/dev/null || \
    ffmpeg -y -v error -i "$input" \
        -vf "scale=${width}:${height}:force_original_aspect_ratio=decrease,pad=${width}:${height}:(ow-iw)/2:(oh-ih)/2:color=00000000" \
        -q:v 2 \
        "$output" 2>/dev/null

    if [[ -f "$output" ]]; then
        log_info "Created: $output"
    else
        log_error "Failed to create: $output"
        return 1
    fi
}

convert_format() {
    local input="$1"
    local target_format="$2"

    if [[ ! -f "$input" ]]; then
        log_error "Input file not found: $input"
        return 1
    fi

    if ! is_supported_format "$(get_extension "$input")"; then
        log_error "Unsupported format: $(get_extension "$input")"
        return 1
    fi

    if ! is_supported_format "$target_format"; then
        log_error "Unsupported target format: $target_format"
        return 1
    fi

    local base_name
    base_name=$(get_base_name "$input")
    local ext
    ext=$(get_extension "$input")
    local output="${ASSETS_DIR}/${base_name}.${target_format}"

    if ! should_overwrite "$output"; then
        log_info "Skipped: $output"
        return 0
    fi

    log_info "Converting $input -> $output"

    case "$target_format" in
        webp)
            ffmpeg -y -v error -i "$input" -c libwebp -q 85 "$output" 2>/dev/null
            ;;
        png)
            ffmpeg -y -v error -i "$input" -c:v png "$output" 2>/dev/null || \
            ffmpeg -y -v error -i "$input" "$output" 2>/dev/null
            ;;
        jpg|jpeg)
            ffmpeg -y -v error -i "$input" -q:v 2 "$output" 2>/dev/null
            ;;
        *)
            log_error "Unsupported format: $target_format"
            return 1
            ;;
    esac

    if [[ -f "$output" ]]; then
        log_info "Created: $output"
    else
        log_error "Failed to create: $output"
        return 1
    fi
}

generate_thumbnails() {
    local input="$1"
    local sizes=(32 64 128 256)

    for size in "${sizes[@]}"; do
        resize_image "$input" "$size" "$size"
    done
}

generate_favicon() {
    local input="$1"
    local sizes=("16x16" "32x32" "180x180")

    for dim in "${sizes[@]}"; do
        local width="${dim%x*}"
        local height="${dim#*x}"
        resize_image "$input" "$width" "$height"
    done
}

generate_email() {
    local input="$1"
    resize_image "$input" 320 100
    resize_image "$input" 600 240
}

generate_banner() {
    local input="$1"
    resize_image "$input" 1200 630
    resize_image "$input" 1200 675
}

generate_preset() {
    local input="$1"
    local preset="$2"

    case "$preset" in
        thumbnail) generate_thumbnails "$input" ;;
        favicon) generate_favicon "$input" ;;
        email) generate_email "$input" ;;
        banner) generate_banner "$input" ;;
        *)
            log_error "Unknown preset: $preset"
            log_info "Available presets: thumbnail, favicon, email, banner"
            return 1
            ;;
    esac
}

generate_all() {
    local input="$1"

    generate_thumbnails "$input"
    generate_favicon "$input"
    generate_email "$input"
    generate_banner "$input"

    log_info "Generated all presets for: $input"
}

process_file() {
    local file="$1"

    if [[ ! -f "$file" ]]; then
        log_error "File not found: $file"
        return 1
    fi

    local ext
    ext=$(get_extension "$file")

    if [[ "$ext" == "svg" ]]; then
        log_info "Skipping SVG (vector format): $file"
        return 0
    fi

    case "$CMD" in
        resize)
            resize_image "$file" "${WIDTH:-}" "${HEIGHT:-}" "${OUTPUT:-}"
            ;;
        convert)
            convert_format "$file" "${FORMAT:-}"
            ;;
        generate)
            generate_all "$file"
            ;;
        preset)
            generate_preset "$file" "${PRESET:-}"
            ;;
        batch)
            generate_all "$file"
            ;;
    esac
}

batch_process() {
    if [[ -n "${SINGLE_FILE:-}" ]]; then
        process_file "$SINGLE_FILE"
        return
    fi

    if [[ ! -d "$ASSETS_DIR" ]]; then
        log_error "Assets directory not found: $ASSETS_DIR"
        exit 1
    fi

    log_info "Processing all images in: $ASSETS_DIR"

    local count=0
    for img in "$ASSETS_DIR"/*.png "$ASSETS_DIR"/*.jpg "$ASSETS_DIR"/*.jpeg "$ASSETS_DIR"/*.webp; do
        if [[ -f "$img" ]]; then
            process_file "$img"
            ((count++)) || true
        fi
    done

    log_info "Processed $count images"
}

show_help() {
    cat <<EOF
Image Tools - Image resizing and format conversion for ff-assets

Usage: $0 <command> [options]

Commands:
    resize <image> <width> <height> [output]
        Resize image to specified dimensions (maintains aspect ratio)

    convert <image> <format>
        Convert image to another format (png, jpg, webp)

    generate <image>
        Generate all presets (thumbnail, favicon, email, banner)

    preset <image> <preset_name>
        Generate specific preset:
        - thumbnail: 32, 64, 128, 256px squares
        - favicon: 16x16, 32x32, 180x180
        - email: 320x100, 600x240
        - banner: 1200x630, 1200x675

    batch
        Process all images in assets/

    help
        Show this help message

Examples:
    $0 resize logo.png 800 600
    $0 convert logo.png webp
    $0 generate logo.png
    $0 preset logo.png thumbnail
    $0 batch

EOF
}

CMD="${1:-}"
OVERWRITE_ALL=false
SINGLE_FILE=""

case "$CMD" in
    resize)
        CMD="resize"
        SINGLE_FILE="${2:-}"
        WIDTH="${3:-}"
        HEIGHT="${4:-}"
        OUTPUT="${5:-}"
        if [[ -z "$SINGLE_FILE" || -z "$WIDTH" || -z "$HEIGHT" ]]; then
            log_error "Missing arguments"
            show_help
            exit 1
        fi
        if [[ ! -f "$SINGLE_FILE" ]]; then
            log_error "File not found: $SINGLE_FILE"
            exit 1
        fi
        batch_process
        ;;
    convert)
        CMD="convert"
        SINGLE_FILE="${2:-}"
        FORMAT="${3:-}"
        if [[ -z "$SINGLE_FILE" || -z "$FORMAT" ]]; then
            log_error "Missing arguments"
            show_help
            exit 1
        fi
        if [[ ! -f "$SINGLE_FILE" ]]; then
            log_error "File not found: $SINGLE_FILE"
            exit 1
        fi
        batch_process
        ;;
    generate)
        CMD="generate"
        SINGLE_FILE="${2:-}"
        if [[ -z "$SINGLE_FILE" ]]; then
            log_error "Missing image argument"
            show_help
            exit 1
        fi
        if [[ ! -f "$SINGLE_FILE" ]]; then
            log_error "File not found: $SINGLE_FILE"
            exit 1
        fi
        batch_process
        ;;
    preset)
        CMD="preset"
        SINGLE_FILE="${2:-}"
        PRESET="${3:-}"
        if [[ -z "$SINGLE_FILE" || -z "$PRESET" ]]; then
            log_error "Missing arguments"
            show_help
            exit 1
        fi
        if [[ ! -f "$SINGLE_FILE" ]]; then
            log_error "File not found: $SINGLE_FILE"
            exit 1
        fi
        batch_process
        ;;
    batch)
        batch_process
        ;;
    help|--help|-h)
        show_help
        ;;
    "")
        show_help
        ;;
    *)
        log_error "Unknown command: $CMD"
        show_help
        exit 1
        ;;
esac
