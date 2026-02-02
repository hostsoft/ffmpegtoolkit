#!/usr/bin/env bash
# libvorbis (depends on ogg)

build_vorbis() {
    local name="libvorbis"
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/libvorbis-${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/libvorbis-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
