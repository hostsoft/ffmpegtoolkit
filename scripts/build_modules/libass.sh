#!/usr/bin/env bash
# libass - subtitle renderer
# Depends: freetype, fribidi, fontconfig (system)

build_libass() {
    local name="libass"
    local version
    version=$(get_component_version "$name") || { log_error "Cannot get version for $name"; return 1; }
    local archive="libass-${version}.tar.gz"
    local tarball="$DOWNLOADS_DIR/$archive"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    log_info "[$name] Unpacking ..."
    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/libass-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    _merge_pkgconfig_to_lib
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
