#!/usr/bin/env bash
# NASM assembler - required by x264, etc.
# Must be sourced after common.sh

build_nasm() {
    local name="nasm"
    if [[ "${FORCE_REBUILD:-0}" != "1" ]] && check_version_match "$name" 2>/dev/null; then
        log_info "[$name] Version matches, skipping"; return 0
    fi
    local version
    version=$(get_component_version "$name") || { log_error "Cannot get version for $name"; return 1; }
    local archive="nasm-${version}.tar.gz"
    local tarball="$DOWNLOADS_DIR/$archive"

    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    log_info "[$name] Unpacking ..."
    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/nasm-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    log_info "[$name] Configuring ..."
    ./configure --prefix="$PREFIX" || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
