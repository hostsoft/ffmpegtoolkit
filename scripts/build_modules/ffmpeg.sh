#!/usr/bin/env bash
# FFmpeg - main encoder (depends on all above)
# Run ldconfig after install

build_ffmpeg() {
    local name="ffmpeg"
    if [[ "${FORCE_REBUILD:-0}" != "1" ]] && check_version_match "$name" 2>/dev/null; then
        log_info "[$name] Version matches, skipping"; return 0
    fi
    local version
    version=$(get_component_version "$name") || return 1
    local tarball="$DOWNLOADS_DIR/ffmpeg-${version}.tar.xz"
    [[ ! -f "$tarball" ]] && { log_error "Source not found: $tarball"; return 1; }

    mkdir -p "$BUILD_DIR"
    rm -rf "$BUILD_DIR/ffmpeg-"*
    tar xf "$tarball" -C "$BUILD_DIR" || return 1
    local extracted
    extracted=$(tar tf "$tarball" 2>/dev/null | head -1 | cut -d/ -f1)
    cd "$BUILD_DIR/$extracted" || return 1

    # Ensure pkg-config finds our built libs (zimg, libjxl, libass, etc.)
    export PKG_CONFIG_PATH="${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_PATH:-}"
    export PKG_CONFIG_LIBDIR="${PREFIX}/lib/pkgconfig:${PREFIX}/lib64/pkgconfig:${PKG_CONFIG_LIBDIR:-}"

    local extra_cflags="-I${PREFIX}/include"
    local extra_ldflags="-L${PREFIX}/lib -L${PREFIX}/lib64"
    # Static link: libjxl_threads needs -lstdc++ -lpthread; libzimg needs -lm (log10f)
    local extra_libs="-lstdc++ -lpthread -lm"
    [[ -n "${CUDA_HOME:-}" ]] && extra_cflags="-I${CUDA_HOME}/include $extra_cflags"
    [[ -n "${CUDA_HOME:-}" ]] && extra_ldflags="-L${CUDA_HOME}/lib64 $extra_ldflags"

    ./configure --prefix="$PREFIX" \
        --pkg-config-flags="--static" \
        --extra-cflags="$extra_cflags" \
        --extra-ldflags="$extra_ldflags" \
        --extra-libs="$extra_libs" \
        --enable-gpl --enable-version3 --enable-static \
        --enable-libx264 --enable-libx265 --enable-libvpx --enable-libaom \
        --enable-libsvtav1 --enable-libopenh264 --enable-libvmaf \
        --enable-libilbc --enable-libjxl \
        --enable-libmp3lame --enable-libopus --enable-libvorbis --enable-libtheora \
        --enable-libwebp --enable-libass --enable-libfreetype --enable-libfribidi \
        --enable-libzimg --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvo-amrwbenc \
        --enable-swscale --enable-avfilter \
        --disable-debug --enable-runtime-cpudetect \
        --enable-libfdk-aac --enable-nonfree \
        || return 1

    safe_make || return 1
    make install || return 1

    run_ldconfig
    cd "$TOOLKIT_ROOT" || true
    rm -rf "$BUILD_DIR/$extracted"
    touch "${BUILD_DIR}/.done_${name}"
}
