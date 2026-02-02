#!/usr/bin/env bash
# xvid - MPEG-4 encoder

build_xvid() {
    local name="xvid"
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/xvidcore-${version}.tar.gz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/xvidcore-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    cd "$BUILD_DIR/xvidcore/build/generic" || return 1

    ./configure --prefix="$PREFIX" --enable-static --disable-shared || return 1
    safe_make || return 1
    rm -f "$PREFIX/lib/libxvidcore.so" "$PREFIX/lib/libxvidcore.so.4" "$PREFIX/lib64/libxvidcore.so" "$PREFIX/lib64/libxvidcore.so.4" 2>/dev/null || true
    make install || return 1

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/xvidcore"
    touch "${BUILD_DIR}/.done_${name}"
}
