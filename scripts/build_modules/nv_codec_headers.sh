#!/usr/bin/env bash
# nv-codec-headers: NVIDIA video codec headers for NVENC/NVDEC
# Must be sourced after common.sh

build_nv_codec_headers() {
    local name="nv-codec-headers"
    local version
    version=$(get_component_version "$name") || { log_error "Cannot get version for $name"; return 1; }
    local archive="nv-codec-headers-n${version}.tar.gz"
    local tarball="$DOWNLOADS_DIR/$archive"

    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball (run ./build.sh fetch)"; return 1; }

    log_info "[$name] Unpacking ..."
    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/nv-codec-headers-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    log_info "[$name] Installing (headers only, make install)..."
    make install PREFIX="$PREFIX" || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
