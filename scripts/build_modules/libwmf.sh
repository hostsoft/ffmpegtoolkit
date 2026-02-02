#!/usr/bin/env bash
# libwmf - WMF graphics library

build_libwmf() {
    local name="libwmf"
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/libwmf-${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/libwmf-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    local cflags=""
    if pkg-config --exists freetype2 2>/dev/null; then
        cflags="$(pkg-config --cflags freetype2) $cflags"
    else
        [[ -d /usr/include/freetype2 ]] && cflags="-I/usr/include/freetype2 $cflags"
    fi
    export CPPFLAGS="${cflags}${CPPFLAGS:+ }${CPPFLAGS:-}"
    export CFLAGS="${cflags}${CFLAGS:+ }${CFLAGS:-}"

    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
