#!/usr/bin/env bash
# dav1d - AV1 decoder (meson/ninja)

build_dav1d() {
    local name="dav1d"
    local srcdir="$BUILD_DIR/dav1d"
    local blddir="$BUILD_DIR/dav1d_build"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir" "$blddir"

    git clone --depth 1 https://code.videolan.org/videolan/dav1d.git "$srcdir"
    mkdir -p "$blddir"
    cd "$blddir" || return 1

    meson setup --prefix="$PREFIX" --libdir="$PREFIX/lib" -Ddefault_library=static "$srcdir" .
    ninja
    ninja install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir" "$blddir"
    touch "${BUILD_DIR}/.done_${name}"
}
