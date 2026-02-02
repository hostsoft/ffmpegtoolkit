#!/usr/bin/env bash
# ffmpeg-toolkit - Main entry script
# Usage: ./build.sh [fetch|dist|--mode=quick|static|compile] [--with-cuda] [--with-qsv] [--exclude=mod] [--pack] [--clean]

set -euo pipefail
TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$TOOLKIT_ROOT"

# shellcheck source=scripts/common.sh
source "$TOOLKIT_ROOT/scripts/common.sh" || { echo "ERROR: Failed to source common.sh"; exit 1; }
# shellcheck source=scripts/env_check.sh
source "$TOOLKIT_ROOT/scripts/env_check.sh" || { echo "ERROR: Failed to source env_check.sh"; exit 1; }

DOWNLOADS_DIR="$TOOLKIT_ROOT/downloads"
VERSIONS_FILE="$TOOLKIT_ROOT/versions.txt"
INSTALL_PREFIX="${PREFIX:-/opt/ffmpeg-toolkit}"

# Parsed options
BUILD_MODE="compile"
WITH_CUDA=0
WITH_QSV=0
EXCLUDE_MODULES=()
DO_PACK=0
DO_CLEAN=0
DO_FORCE=0
BUILD_ONLY=""
DO_LINK=0
DO_UNLINK=0
DO_LINK_PATH=0
DO_UNLINK_PATH=0

# Build module order (name -> script without .sh)
BUILD_MODULES=(
    nasm yasm nv_codec_headers nv_cuda
    ogg vorbis theora fishsound speex flac opus
    opencoreamr amrwbenc a52dec libao
    lame fdkaac faad2 aacenc dav1d soxr libsrt libass aribb24
    zimg libwebp libwmf vidstab xvid vpx aom x264 x265
    vorbistools gsm neroaacenc kvazaar uavs3d
    svtav1 openh264 libvmaf libilbc libjxl
    ffmpeg
)

# -----------------------------------------------------------------------------
# Parse arguments
# -----------------------------------------------------------------------------
parse_args() {
    for arg in "$@"; do
        case "$arg" in
            --mode=*)
                BUILD_MODE="${arg#*=}"
                ;;
            --with-cuda)
                WITH_CUDA=1
                ;;
            --with-qsv)
                WITH_QSV=1
                ;;
            --exclude=*)
                IFS=',' read -ra mods <<< "${arg#*=}"
                EXCLUDE_MODULES+=("${mods[@]}")
                ;;
            --pack)
                DO_PACK=1
                ;;
            --clean)
                DO_CLEAN=1
                ;;
            --force)
                DO_FORCE=1
                ;;
            --only=*)
                BUILD_ONLY="${arg#*=}"
                ;;
            --link)
                DO_LINK=1
                ;;
            --unlink)
                DO_UNLINK=1
                ;;
            --link-path)
                DO_LINK_PATH=1
                ;;
            --unlink-path)
                DO_UNLINK_PATH=1
                ;;
            --help|-h)
                show_usage
                exit 0
                ;;
        esac
    done
}

show_usage() {
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  fetch              Download all source packages to downloads/"
    echo "  dist               Pack project to ffmpegtoolkit-YYYYMMDD-HHMMSS.tar.gz"
    echo "  deps               Install build dependencies (gcc, cmake, etc.) - requires root"
    echo "  build              Alias for --mode=compile"
    echo "  ldconfig           Register PREFIX/lib in loader path (need root, fix 'cannot open shared object')"
    echo ""
    echo "Options:"
    echo "  --mode=quick       Install pre-built binary (johnvansickle)"
    echo "  --mode=static      Extract pre-compiled static package (set STATIC_PKG=path)"
    echo "  --mode=compile     Full compile from source (default)"
    echo "  --with-cuda        Enable CUDA/NVENC build"
    echo "  --with-qsv         Enable Intel QSV"
    echo "  --exclude=mod      Skip module(s), e.g. --exclude=x265 or --exclude=x264,x265"
    echo "  --only=mod         Build only this module, e.g. --only=ffmpeg (skip others)"
    echo "  --force            Force rebuild all (ignore .done_* stamps)"
    echo "  --link             Create symlinks: ffmpeg, ffprobe -> /usr/local/bin (need root)"
    echo "  --unlink           Remove symlinks from /usr/local/bin"
    echo "  --link-path        Add PREFIX/bin to system PATH via /etc/profile.d (need root)"
    echo "  --unlink-path      Remove /etc/profile.d/ffmpeg-toolkit.sh"
    echo "  --pack             Same as dist"
    echo "  --clean            Clean build artifacts"
    echo ""
    echo "Examples:"
    echo "  $0 --mode=quick"
    echo "  $0 --mode=compile --with-cuda --exclude=x265"
    echo "  $0 build --only=ffmpeg   # build ffmpeg only (skip already-built deps)"
    echo "  $0 build --force         # force rebuild all"
    echo "  sudo $0 --link           # symlink ffmpeg/ffprobe to /usr/local/bin"
    echo "  sudo $0 --unlink         # remove those symlinks"
    echo "  sudo $0 --link-path      # add toolkit bin to system PATH"
    echo "  sudo $0 ldconfig         # fix: error while loading shared libraries (register PREFIX/lib)"
    echo "  $0 fetch"
}

# -----------------------------------------------------------------------------
# Symlink: ffmpeg, ffprobe -> /usr/local/bin
# -----------------------------------------------------------------------------
cmd_link() {
    local prefix="${PREFIX:-$INSTALL_PREFIX}"
    local bin_dir="$prefix/bin"
    local target_dir="/usr/local/bin"
    [[ -d "$bin_dir" ]] || { log_error "Not found: $bin_dir (build first)"; return 1; }
    for exe in ffmpeg ffprobe ffplay; do
        [[ -x "$bin_dir/$exe" ]] || continue
        if [[ -L "$target_dir/$exe" ]] && [[ "$(readlink "$target_dir/$exe" 2>/dev/null)" == "$bin_dir/$exe" ]]; then
            log_info "[$exe] Already linked: $target_dir/$exe -> $bin_dir/$exe"
        else
            ln -sf "$bin_dir/$exe" "$target_dir/$exe" && log_info "[$exe] Linked: $target_dir/$exe -> $bin_dir/$exe" || log_warn "[$exe] Link failed (try sudo)"
        fi
    done
}

cmd_unlink() {
    local target_dir="/usr/local/bin"
    for exe in ffmpeg ffprobe ffplay; do
        if [[ -L "$target_dir/$exe" ]]; then
            local dest; dest=$(readlink "$target_dir/$exe" 2>/dev/null)
            if [[ "$dest" == *"/opt/ffmpeg-toolkit"* ]] || [[ "$dest" == *"ffmpeg-toolkit"* ]]; then
                rm -f "$target_dir/$exe" && log_info "[$exe] Removed: $target_dir/$exe" || log_warn "[$exe] Remove failed (try sudo)"
            else
                log_info "[$exe] Skip (not toolkit link): $target_dir/$exe -> $dest"
            fi
        fi
    done
}

# -----------------------------------------------------------------------------
# Add PREFIX/bin to system PATH (/etc/profile.d/ffmpeg-toolkit.sh)
# -----------------------------------------------------------------------------
cmd_link_path() {
    local prefix="${PREFIX:-$INSTALL_PREFIX}"
    local profile_d="/etc/profile.d/ffmpeg-toolkit.sh"
    local content="# Add ffmpeg-toolkit to PATH
export PATH=\"${prefix}/bin:\$PATH\"
"
    if printf '%s' "$content" > "$profile_d" 2>/dev/null; then
        log_info "Created $profile_d (PREFIX/bin added to PATH for new shells)"
    else
        log_error "Failed to write $profile_d (run with sudo)"
        return 1
    fi
}

cmd_unlink_path() {
    local profile_d="/etc/profile.d/ffmpeg-toolkit.sh"
    if [[ -f "$profile_d" ]]; then
        rm -f "$profile_d" && log_info "Removed $profile_d" || { log_warn "Remove failed (try sudo)"; return 1; }
    else
        log_info "Not found: $profile_d"
    fi
}

# -----------------------------------------------------------------------------
# Check if module is excluded
# -----------------------------------------------------------------------------
is_excluded() {
    local m="$1"
    for ex in "${EXCLUDE_MODULES[@]}"; do
        [[ "$m" == "$ex" ]] && return 0
    done
    return 1
}

# -----------------------------------------------------------------------------
# Get component download URL and local filename
# -----------------------------------------------------------------------------
get_fetch_info() {
    local name="$1"
    local version="$2"
    local filename="" url=""
    case "$name" in
        ffmpeg) filename="ffmpeg-${version}.tar.xz"; url="https://ffmpeg.org/releases/${filename}" ;;
        x264) filename="x264-master.tar.gz"; url="https://code.videolan.org/videolan/x264/-/archive/master/x264-master.tar.gz" ;;
        x265) filename="x265_${version}.tar.gz"; url="http://ftp.videolan.org/pub/videolan/x265/x265_${version}.tar.gz" ;;
        libwebp) filename="libwebp-${version}.tar.gz"; url="https://storage.googleapis.com/downloads.webmproject.org/releases/webp/${filename}" ;;
        libvmaf) filename="vmaf-v${version}.tar.gz"; url="https://github.com/Netflix/vmaf/archive/refs/tags/v${version}.tar.gz" ;;
        openssl) filename="openssl-${version}.tar.gz"; url="https://www.openssl.org/source/${filename}" ;;
        nv-codec-headers) filename="nv-codec-headers-n${version}.tar.gz"; url="https://github.com/FFmpeg/nv-codec-headers/archive/refs/tags/n${version}.tar.gz" ;;
        nasm) filename="nasm-${version}.tar.gz"; url="https://www.nasm.us/pub/nasm/releasebuilds/${version}/${filename}" ;;
        yasm) filename="yasm-${version}.tar.gz"; url="https://www.tortall.net/projects/yasm/releases/${filename}" ;;
        libass) filename="libass-${version}.tar.gz"; url="https://github.com/libass/libass/releases/download/${version}/${filename}" ;;
        a52dec) filename="a52dec-${version}.tar.gz"; url="https://ftp.osuosl.org/pub/blfs/conglomeration/a52dec/${filename}" ;;
        libao) filename="libao-${version}.tar.gz"; url="https://downloads.xiph.org/releases/ao/${filename}" ;;
        libwmf) filename="libwmf-${version}.tar.gz"; url="https://github.com/caolanm/libwmf/archive/refs/tags/v${version}.tar.gz" ;;
        speex) filename="speex-${version}.tar.gz"; url="https://downloads.xiph.org/releases/speex/${filename}" ;;
        flac) filename="flac-${version}.tar.xz"; url="https://ftp.osuosl.org/pub/xiph/releases/flac/${filename}" ;;
        lame) filename="lame-${version}.tar.gz"; url="https://ftp.osuosl.org/pub/blfs/conglomeration/lame/${filename}" ;;
        opus) filename="opus-${version}.tar.gz"; url="https://downloads.xiph.org/releases/opus/${filename}" ;;
        ogg) filename="libogg-${version}.tar.gz"; url="https://ftp.osuosl.org/pub/xiph/releases/ogg/${filename}" ;;
        liboggz) filename="liboggz-${version}.tar.gz"; url="https://downloads.xiph.org/releases/liboggz/${filename}" ;;
        libvorbis) filename="libvorbis-${version}.tar.gz"; url="https://downloads.xiph.org/releases/vorbis/${filename}" ;;
        amrwbenc) filename="vo-amrwbenc-${version}.tar.gz"; url="https://sourceforge.net/projects/opencore-amr/files/vo-amrwbenc/${filename}/download" ;;
        opencore-amr) filename="opencore-amr-${version}.tar.gz"; url="https://sourceforge.net/projects/opencore-amr/files/opencore-amr/${filename}/download" ;;
        theora) filename="libtheora-${version}.tar.gz"; url="https://ftp.osuosl.org/pub/xiph/releases/theora/${filename}" ;;
        libfishsound) filename="libfishsound-${version}.tar.gz"; url="https://downloads.xiph.org/releases/libfishsound/${filename}" ;;
        soxr) filename="soxr-${version}-Source.tar.xz"; url="https://download.videolan.org/contrib/soxr/${filename}" ;;
        vorbis) filename="vorbis-tools-${version}.tar.gz"; url="https://downloads.xiph.org/releases/vorbis/${filename}" ;;
        xvid) filename="xvidcore-${version}.tar.gz"; url="https://downloads.xvid.com/downloads/${filename}" ;;
        svtav1) filename="SVT-AV1-v${version}.tar.gz"; url="https://gitlab.com/AOMediaCodec/SVT-AV1/-/archive/v${version}/SVT-AV1-v${version}.tar.gz" ;;
        openh264) filename="openh264-v${version}.tar.gz"; url="https://github.com/cisco/openh264/archive/refs/tags/v${version}.tar.gz" ;;
        libilbc) filename="libilbc-v${version}.tar.gz"; url="https://github.com/TimothyGu/libilbc/archive/refs/tags/v${version}.tar.gz" ;;
        libjxl) filename=""; url=""; ;; # git clone (handled in cmd_fetch)
        *)
            return 1
            ;;
    esac
    echo "$filename $url"
}

fetch_component() {
    local name="$1" version="$2"
    local info; info=$(get_fetch_info "$name" "$version")
    local filename="${info%% *}" url="${info#* }"
    mkdir -p "$DOWNLOADS_DIR"
    local dest="$DOWNLOADS_DIR/$filename"
    [[ -f "$dest" ]] && { log_info "[$name] Cached: $filename"; return 0; }
    log_info "[$name] Downloading: $url"
    command -v wget &>/dev/null || { log_error "wget not found"; return 1; }
    wget -q --show-progress -O "$dest" "$url" || { log_error "[$name] Download failed"; rm -f "$dest"; return 1; }
}

# -----------------------------------------------------------------------------
# cmd_fetch: Download all source packages
# -----------------------------------------------------------------------------
cmd_fetch() {
    log_info "Fetching all source packages..."
    local failed=0
    while IFS= read -r line; do
        [[ "$line" =~ ^[[:space:]]*# ]] || [[ -z "${line// }" ]] && continue
        name="${line%%=*}"; name="${name//[[:space:]]/}"
        version="${line#*=}"; version="${version%%#*}"; version="${version//[[:space:]]/}"
        [[ -z "$name" || -z "$version" ]] && continue
        if [[ "$name" == "libjxl" ]]; then
            [[ -d "$DOWNLOADS_DIR/libjxl_repo" ]] && { log_info "[libjxl] Cached: libjxl_repo"; continue; }
            log_info "[libjxl] Cloning from GitHub (--recursive)..."
            mkdir -p "$DOWNLOADS_DIR"
            (cd "$DOWNLOADS_DIR" && git clone --recurse-submodules https://github.com/libjxl/libjxl.git libjxl_repo) || ((failed++)) || true
            continue
        fi
        get_fetch_info "$name" "$version" >/dev/null 2>&1 || continue
        fetch_component "$name" "$version" || ((failed++)) || true
    done < "$VERSIONS_FILE"
    [[ $failed -gt 0 ]] && { log_error "Fetch: $failed failure(s)"; return 1; }
    log_info "Fetch completed."
}

# -----------------------------------------------------------------------------
# cmd_quick: Install pre-built binary (johnvansickle static)
# -----------------------------------------------------------------------------
cmd_quick() {
    log_info "Mode: quick - installing pre-built FFmpeg binary..."
    local url="https://johnvansickle.com/ffmpeg/releases/ffmpeg-release-amd64-static.tar.xz"
    local tarball="ffmpeg-release-amd64-static.tar.xz"
    [[ -f "$tarball" ]] && rm -rf "$tarball"
    wget -q --show-progress -O "$tarball" "$url" || { log_error "Download failed"; return 1; }
    tar xf "$tarball"
    local dir; dir=$(tar tf "$tarball" | head -1 | cut -d/ -f1)
    [[ -z "$dir" ]] && dir="ffmpeg-7.0.2-amd64-static"
    [[ -d "$INSTALL_PREFIX" ]] && rm -rf "$INSTALL_PREFIX"
    mkdir -p "$(dirname "$INSTALL_PREFIX")"
    mv "$dir" "$INSTALL_PREFIX"
    ln -sf "$INSTALL_PREFIX/ffprobe" /usr/bin/ffprobe
    ln -sf "$INSTALL_PREFIX/ffmpeg" /usr/bin/ffmpeg
    ln -sf "$INSTALL_PREFIX/ffmpeg" /usr/local/bin/ffmpeg
    ln -sf "$INSTALL_PREFIX/qt-faststart" /usr/bin/qt-faststart
    rm -f "$tarball"
    log_info "Quick install completed: $INSTALL_PREFIX"
}

# -----------------------------------------------------------------------------
# cmd_static: Extract pre-compiled static package
# -----------------------------------------------------------------------------
cmd_static() {
    log_info "Mode: static - extract pre-compiled package..."
    local pkg="${STATIC_PKG:-ffmpeg-release-amd64-static.tar.xz}"
    [[ ! -f "$pkg" ]] && { log_error "Static package not found: $pkg (set STATIC_PKG=path)"; return 1; }
    tar xf "$pkg"
    local dir; dir=$(tar tf "$pkg" | head -1 | cut -d/ -f1)
    [[ -d "$INSTALL_PREFIX" ]] && rm -rf "$INSTALL_PREFIX"
    mv "$dir" "$INSTALL_PREFIX"
    ln -sf "$INSTALL_PREFIX/ffprobe" /usr/bin/ffprobe
    ln -sf "$INSTALL_PREFIX/ffmpeg" /usr/bin/ffmpeg
    ln -sf "$INSTALL_PREFIX/ffmpeg" /usr/local/bin/ffmpeg
    ln -sf "$INSTALL_PREFIX/qt-faststart" /usr/bin/qt-faststart
    log_info "Static install completed: $INSTALL_PREFIX"
}

# -----------------------------------------------------------------------------
# cmd_clean: Clean build artifacts
# -----------------------------------------------------------------------------
cmd_clean() {
    log_info "Cleaning build artifacts..."
    rm -rf "$TOOLKIT_ROOT/build"
    rm -rf "$TOOLKIT_ROOT/downloads"/*.tar.gz "$TOOLKIT_ROOT/downloads"/*.tar.xz "$TOOLKIT_ROOT/downloads"/*.tar.bz2 "$TOOLKIT_ROOT/downloads"/*.zip 2>/dev/null || true
    rm -f ffmpeg-release-amd64-static.tar.xz
    find "$TOOLKIT_ROOT" -maxdepth 1 -name "ffmpegtoolkit-*.tar.gz" -delete 2>/dev/null || true
    log_info "Clean completed."
}

# -----------------------------------------------------------------------------
# cmd_dist / cmd_pack: Pack project for distribution
# Pack from parent dir to avoid "tar: .: file changed as we read it"
# Output: <parent>/ffmpegtoolkit-YYYYMMDD-HHMMSS.tar.gz
# -----------------------------------------------------------------------------
cmd_dist() {
    local parent_dir dir_name output_name output_path
    parent_dir=$(dirname "$TOOLKIT_ROOT")
    dir_name=$(basename "$TOOLKIT_ROOT")
    output_name="ffmpegtoolkit-$(date +%Y%m%d-%H%M%S).tar.gz"
    output_path="$parent_dir/$output_name"
    log_info "Packing to $output_path ..."
    tar czf "$output_path" -C "$parent_dir" \
        --exclude="$dir_name/.git" \
        --exclude="$dir_name/ffmpegtoolkit-*.tar.gz" \
        "$dir_name"
    log_info "Dist completed: $output_path"
}

# -----------------------------------------------------------------------------
# cmd_compile: Full compile with progress bar
# -----------------------------------------------------------------------------
cmd_compile() {
    log_info "=== Starting full compile (mode: compile) ==="
    log_info "TOOLKIT_ROOT=$TOOLKIT_ROOT PREFIX=${INSTALL_PREFIX}"
    source "$TOOLKIT_ROOT/scripts/dep_manager.sh"

    if ! command -v gcc &>/dev/null && ! command -v cc &>/dev/null; then
        log_error "No C compiler found. Run: sudo $0 deps"
        return 1
    fi
    source "$TOOLKIT_ROOT/scripts/ldconfig_setup.sh" 2>/dev/null || true
    [[ "${INSTALL_DEPS:-0}" == "1" ]] && install_build_deps
    [[ "${SETUP_LDCONFIG:-0}" == "1" ]] && setup_ldconfig

    export PREFIX="$INSTALL_PREFIX"
    export FORCE_REBUILD="${DO_FORCE:-0}"
    [[ $WITH_CUDA -eq 1 ]] && export WITH_CUDA=1
    [[ $WITH_QSV -eq 1 ]] && export HAS_QSV=true

    log_info "Loading build modules..."
    local moddir="$TOOLKIT_ROOT/scripts/build_modules"
    for m in "${BUILD_MODULES[@]}"; do
        if [[ -f "$moddir/${m}.sh" ]]; then
            source "$moddir/${m}.sh" || { log_error "Failed to source $m.sh"; return 1; }
        fi
    done

    local total=0
    for m in "${BUILD_MODULES[@]}"; do
        is_excluded "$m" && continue || true
        [[ "$m" == "nv_cuda" ]] && [[ $WITH_CUDA -ne 1 ]] && continue || true
        [[ -n "$BUILD_ONLY" ]] && [[ "$m" != "$BUILD_ONLY" ]] && continue || true
        [[ $DO_FORCE -eq 0 ]] && [[ -f "${BUILD_DIR}/.done_${m}" ]] && continue || true
        ((total++)) || true
    done

    [[ $total -eq 0 ]] && { log_warn "No modules to build (all excluded/skipped?)"; return 0; }
    log_info "Building $total module(s)..."

    local current=0
    for m in "${BUILD_MODULES[@]}"; do
        is_excluded "$m" && continue || true
        [[ "$m" == "nv_cuda" ]] && [[ $WITH_CUDA -ne 1 ]] && continue || true
        [[ -n "$BUILD_ONLY" ]] && [[ "$m" != "$BUILD_ONLY" ]] && continue || true
        [[ $DO_FORCE -eq 0 ]] && [[ -f "${BUILD_DIR}/.done_${m}" ]] && { log_info "Skipping $m (already built)"; continue; } || true

        ((current++)) || true
        local fn="build_${m}"
        if declare -f "$fn" &>/dev/null; then
            echo ""
            log_info "[$current/$total] Compiling $m ..."
            if ! $fn 2>&1 | tee -a "$TOOLKIT_ROOT/logs/${m}.log"; then
                log_error "Build FAILED at component: $m"
                log_error "Check logs: $TOOLKIT_ROOT/logs/${m}.log"
                return 1
            fi
        fi
    done

    run_ldconfig
    log_info "Build completed successfully."
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
parse_args "$@"
mkdir -p "$TOOLKIT_ROOT/logs"

log_info "Command: $0 $* | BUILD_MODE=$BUILD_MODE"

# Handle positional commands first
case "${1:-}" in
    fetch)
        cmd_fetch
        exit 0
        ;;
    dist)
        cmd_dist
        exit 0
        ;;
    deps)
        source "$TOOLKIT_ROOT/scripts/dep_manager.sh" 2>/dev/null || true
        install_build_deps
        exit 0
        ;;
    ldconfig)
        source "$TOOLKIT_ROOT/scripts/ldconfig_setup.sh" 2>/dev/null || true
        export PREFIX="${PREFIX:-$INSTALL_PREFIX}"
        setup_ldconfig || { log_error "Run: sudo $0 ldconfig"; exit 1; }
        exit 0
        ;;
    build)
        BUILD_MODE=compile
        [[ -n "${2:-}" && "${2#--}" == "$2" ]] && BUILD_ONLY="${BUILD_ONLY:-$2}"
        ;;
esac

# Handle --clean
[[ $DO_CLEAN -eq 1 ]] && { cmd_clean; [[ $# -le 1 ]] && exit 0; }

# Handle --link / --unlink / --link-path / --unlink-path
[[ $DO_LINK -eq 1 ]] && { cmd_link; exit 0; }
[[ $DO_UNLINK -eq 1 ]] && { cmd_unlink; exit 0; }
[[ $DO_LINK_PATH -eq 1 ]] && { cmd_link_path; exit 0; }
[[ $DO_UNLINK_PATH -eq 1 ]] && { cmd_unlink_path; exit 0; }

# Handle --pack (alias for dist)
[[ $DO_PACK -eq 1 ]] && { cmd_dist; [[ $# -le 1 ]] && exit 0; }

# Handle --mode
case "$BUILD_MODE" in
    quick)
        cmd_quick
        ;;
    static)
        cmd_static
        ;;
    compile)
        cmd_compile
        ;;
    *)
        log_error "Unknown mode: $BUILD_MODE (use quick|static|compile)"
        show_usage
        exit 1
        ;;
esac
