#!/usr/bin/env bash
# libsrt - Haivision SRT protocol
# Git-based, no versioned tarball in versions.txt

build_libsrt() {
    local name="libsrt"
    local srcdir="$BUILD_DIR/srt"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    log_info "[$name] Cloning from git..."
    git clone --depth 1 https://github.com/Haivision/srt.git "$srcdir"
    cd "$srcdir" || return 1

    log_info "[$name] Configuring (cmake)..."
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DENABLE_SHARED=OFF -DENABLE_STATIC=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON .
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
