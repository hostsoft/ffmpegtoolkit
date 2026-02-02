#!/usr/bin/env bash
# aribb24 - ARIB STD-B24 caption decoder
# Git-based

build_aribb24() {
    local name="aribb24"
    local srcdir="$BUILD_DIR/aribb24"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    log_info "[$name] Cloning from git..."
    git clone https://github.com/nkoriyama/aribb24 "$srcdir"
    cd "$srcdir" || return 1
    ./bootstrap
    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
