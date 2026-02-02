#!/usr/bin/env bash
# a52dec - ATSC A/52 (AC-3) decoder

build_a52dec() {
    local name="a52dec"
    local version
    version=$(get_component_version "$name") || { log_error "Cannot get version"; return 1; }
    local tarball="$DOWNLOADS_DIR/a52dec-${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/a52dec-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    [[ -f bootstrap ]] && ./bootstrap 2>/dev/null || true
    ./configure --prefix="$PREFIX" --enable-static --disable-shared CFLAGS="-fPIC" || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
