#!/usr/bin/env bash
# vid.stab - video stabilization (Git-based)

build_vidstab() {
    local name="vidstab"
    local srcdir="$BUILD_DIR/vid.stab"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone --depth 1 https://github.com/georgmartius/vid.stab "$srcdir"
    cd "$srcdir" || return 1
    cmake -G "Unix Makefiles" -DCMAKE_INSTALL_PREFIX="$PREFIX" -DBUILD_SHARED_LIBS=OFF .
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
