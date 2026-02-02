#!/usr/bin/env bash
# Common functions, color definitions, log engine
# Must be sourced after TOOLKIT_ROOT is set

# -----------------------------------------------------------------------------
# Colors
# -----------------------------------------------------------------------------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# -----------------------------------------------------------------------------
# Unified paths (PREFIX = install target, supports /opt/ffmpeg-toolkit or /usr/local/ffmpegtoolkit)
# -----------------------------------------------------------------------------
PREFIX="${PREFIX:-/opt/ffmpeg-toolkit}"
BUILD_DIR="${BUILD_DIR:-${TOOLKIT_ROOT:-.}/build}"
DOWNLOADS_DIR="${DOWNLOADS_DIR:-${TOOLKIT_ROOT:-.}/downloads}"
export PREFIX BUILD_DIR DOWNLOADS_DIR

# CUDA (optional, for NVENC/NVDEC)
[[ -d /usr/local/cuda ]] && export CUDA_HOME="${CUDA_HOME:-/usr/local/cuda}"

# Build/run environment (include ~/.local/bin for pip-installed tools: meson, ninja)
export PATH="${PREFIX}/bin:${HOME:-/root}/.local/bin:${PATH}"
export LD_LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64:/usr/local/lib:/usr/lib:${LD_LIBRARY_PATH:-}"
export LIBRARY_PATH="${PREFIX}/lib:${PREFIX}/lib64:/usr/lib:/usr/local/lib:${LIBRARY_PATH:-}"
export CPATH="${PREFIX}/include:/usr/include:/usr/local/include:${CPATH:-}"
export C_INCLUDE_PATH="${PREFIX}/include:${C_INCLUDE_PATH:-}"
export CPLUS_INCLUDE_PATH="${PREFIX}/include:${CPLUS_INCLUDE_PATH:-}"
[[ -n "${CUDA_HOME:-}" ]] && export LD_LIBRARY_PATH="${CUDA_HOME}/lib64:${LD_LIBRARY_PATH}"
[[ -n "${CUDA_HOME:-}" ]] && export LIBRARY_PATH="${CUDA_HOME}/lib64:${LIBRARY_PATH}"
[[ -n "${CUDA_HOME:-}" ]] && export CPATH="${CUDA_HOME}/include:${CPATH}"
[[ -n "${CUDA_HOME:-}" ]] && export PATH="${CUDA_HOME}/bin:${PATH}"

# Include Debian/Ubuntu arch-specific pkgconfig (/usr/lib/x86_64-linux-gnu/pkgconfig)
# PREFIX must be first so our built libs (libjxl, etc.) are found before system ones
PKG_CONFIG_BASE="/usr/share/pkgconfig:/usr/lib64/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/lib/aarch64-linux-gnu/pkgconfig:/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/usr/local/lib64/pkgconfig:/lib/pkgconfig"
export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_BASE}"
export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_BASE}:${PKG_CONFIG_PATH:-}"

# -----------------------------------------------------------------------------
# Log engine: tee to terminal and append to logs/main.log
# -----------------------------------------------------------------------------
_log_write() {
    local level="$1"
    shift
    local log_dir="${TOOLKIT_ROOT:-.}/logs"
    mkdir -p "$log_dir"
    local msg="[$(date '+%Y-%m-%d %H:%M:%S')] [$level] $*"
    echo "$msg" >> "$log_dir/main.log"
}

log_info() {
    local msg="[INFO] $*"
    echo -e "${GREEN}${msg}${NC}"
    _log_write "INFO" "$@"
}

log_warn() {
    local msg="[WARN] $*"
    echo -e "${YELLOW}${msg}${NC}"
    _log_write "WARN" "$@"
}

log_error() {
    local msg="[ERROR] $*"
    echo -e "${RED}${msg}${NC}"
    _log_write "ERROR" "$@"
}

# -----------------------------------------------------------------------------
# _merge_pkgconfig_to_lib: unify lib64/pkgconfig -> lib/pkgconfig
# Call after make install when distro may install .pc to lib64
# -----------------------------------------------------------------------------
_merge_pkgconfig_to_lib() {
    [[ -d "${PREFIX}/lib64/pkgconfig" ]] || return 0
    mkdir -p "${PREFIX}/lib/pkgconfig"
    cp -n "${PREFIX}/lib64/pkgconfig/"*.pc "${PREFIX}/lib/pkgconfig/" 2>/dev/null || true
}

# -----------------------------------------------------------------------------
# run_ldconfig: update dynamic linker cache after installing libs
# -----------------------------------------------------------------------------
run_ldconfig() {
    if command -v ldconfig &>/dev/null; then
        ldconfig 2>/dev/null || true
    fi
}

# -----------------------------------------------------------------------------
# safe_make: parallel build with nproc, captures errors
# Returns 0 on success, 1 on failure
# -----------------------------------------------------------------------------
safe_make() {
    local jobs
    jobs=$(nproc 2>/dev/null || echo 1)
    [[ -z "$jobs" || "$jobs" -lt 1 ]] && jobs=1
    log_info "Running make -j$jobs"
    if make -j"$jobs" "$@"; then
        return 0
    else
        local ret=$?
        log_error "make failed with exit code $ret"
        return $ret
    fi
}

# -----------------------------------------------------------------------------
# Get component version from versions.txt
# -----------------------------------------------------------------------------
get_component_version() {
    local component="$1"
    local versions_file="${TOOLKIT_ROOT:-.}/versions.txt"
    [[ ! -f "$versions_file" ]] && return 1
    grep -E "^[[:space:]]*${component}[[:space:]]*=" "$versions_file" 2>/dev/null | head -1 | cut -d= -f2- | sed 's/[[:space:]]*#.*//' | tr -d '[:space:]'
}

# -----------------------------------------------------------------------------
# Get archive filename for component (must match get_fetch_info in build.sh)
# -----------------------------------------------------------------------------
get_component_archive() {
    local name="$1"
    local version="$2"
    case "$name" in
        ffmpeg) echo "ffmpeg-${version}.tar.xz" ;;
        x264) echo "x264-master.tar.gz" ;;
        x265) echo "x265_${version}.tar.gz" ;;
        libwebp) echo "libwebp-${version}.tar.gz" ;;
        libvmaf) echo "vmaf-v${version}.tar.gz" ;;
        openssl) echo "openssl-${version}.tar.gz" ;;
        nv-codec-headers) echo "nv-codec-headers-n${version}.tar.gz" ;;
        nasm) echo "nasm-${version}.tar.gz" ;;
        yasm) echo "yasm-${version}.tar.gz" ;;
        libass) echo "libass-${version}.tar.gz" ;;
        a52dec) echo "a52dec-${version}.tar.gz" ;;
        libao) echo "libao-${version}.tar.gz" ;;
        libwmf) echo "libwmf-${version}.tar.gz" ;;
        speex) echo "speex-${version}.tar.gz" ;;
        flac) echo "flac-${version}.tar.xz" ;;
        lame) echo "lame-${version}.tar.gz" ;;
        opus) echo "opus-${version}.tar.gz" ;;
        ogg) echo "libogg-${version}.tar.gz" ;;
        liboggz) echo "liboggz-${version}.tar.gz" ;;
        libvorbis) echo "libvorbis-${version}.tar.gz" ;;
        amrwbenc) echo "vo-amrwbenc-${version}.tar.gz" ;;
        opencore-amr) echo "opencore-amr-${version}.tar.gz" ;;
        theora) echo "libtheora-${version}.tar.gz" ;;
        libfishsound) echo "libfishsound-${version}.tar.gz" ;;
        soxr) echo "soxr-${version}-Source.tar.xz" ;;
        vorbis) echo "vorbis-tools-${version}.tar.gz" ;;
        xvid) echo "xvidcore-${version}.tar.gz" ;;
        svtav1) echo "SVT-AV1-v${version}.tar.gz" ;;
        openh264) echo "openh264-v${version}.tar.gz" ;;
        libilbc) echo "libilbc-v${version}.tar.gz" ;;
        libjxl) echo "libjxl_repo" ;; # git clone
        *) echo "" ;;
    esac
}

# -----------------------------------------------------------------------------
# Checkpoint: check if installed binary version matches versions.txt
# Returns 0 if match (skip build), 1 if mismatch or not installed
# Usage: check_version_match <component>
# -----------------------------------------------------------------------------
check_version_match() {
    local component="$1"
    [[ -z "$component" ]] && return 1

    local versions_file="${TOOLKIT_ROOT:-.}/versions.txt"
    [[ ! -f "$versions_file" ]] && return 1

    local expected
    expected=$(grep -E "^[[:space:]]*${component}[[:space:]]*=" "$versions_file" 2>/dev/null | head -1 | cut -d= -f2- | tr -d '[:space:]')
    [[ -z "$expected" ]] && return 1

    local actual=""
    local bin_path="${PREFIX}/bin/${component}"

    case "$component" in
        x264)
            [[ "$expected" == "master" ]] && [[ -x "$bin_path" ]] && { return 0; }
            [[ -x "$bin_path" ]] && actual=$("$bin_path" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
            ;;
        libwebp)
            bin_path="${PREFIX}/bin/cwebp"
            [[ -x "$bin_path" ]] && actual=$("$bin_path" -version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            ;;
        x265)
            [[ -x "$bin_path" ]] && actual=$("$bin_path" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+')
            ;;
        ffmpeg)
            bin_path="${PREFIX}/bin/ffmpeg"
            [[ -x "$bin_path" ]] && actual=$("$bin_path" -version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)?')
            ;;
        *)
            # Generic: try running <component> --version and extract first version-like string
            if [[ -x "$bin_path" ]]; then
                actual=$("$bin_path" --version 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+(\.[0-9]+)*' | head -1)
            fi
            ;;
    esac

    [[ -z "$actual" ]] && return 1

    # Match: exact or actual starts with expected (e.g. expected=6.0 matches actual=6.0.1)
    if [[ "$actual" == "$expected" ]] || [[ "$actual" == "$expected"* ]]; then
        return 0
    fi
    return 1
}
