#!/usr/bin/env bash
# libgsm - Makefile-based (no configure), from https://github.com/timothytylee/libgsm

build_gsm() {
    local name="gsm"
    local srcdir="$BUILD_DIR/libgsm"
    [[ -d "$srcdir" ]] && rm -rf "$srcdir"

    git clone --depth 1 https://github.com/timothytylee/libgsm "$srcdir"
    cd "$srcdir" || return 1

    if [[ -f Makefile.gsm ]]; then
        make -f Makefile.gsm all || return 1
    else
        make all 2>/dev/null || make || return 1
    fi
    mkdir -p "$PREFIX/lib" "$PREFIX/include" "$PREFIX/lib64"
    if [[ -f Makefile.gsm ]]; then
        make -f Makefile.gsm install GSM_INSTALL_ROOT="$PREFIX" 2>/dev/null || true
    fi
    if [[ ! -f "$PREFIX/lib/libgsm.a" && ! -f "$PREFIX/lib64/libgsm.a" ]]; then
        make install prefix="$PREFIX" 2>/dev/null || true
    fi
    if [[ ! -f "$PREFIX/lib/libgsm.a" && ! -f "$PREFIX/lib64/libgsm.a" ]]; then
        cp -f lib/libgsm.a "$PREFIX/lib/" 2>/dev/null || cp -f libgsm.a "$PREFIX/lib/" 2>/dev/null || return 1
        cp -f inc/gsm.h "$PREFIX/include/" 2>/dev/null || cp -f gsm.h "$PREFIX/include/" 2>/dev/null || true
        [[ -d "$PREFIX/lib64" ]] && cp -f "$PREFIX/lib/libgsm.a" "$PREFIX/lib64/" 2>/dev/null || true
    fi

    cd "$TOOLKIT_ROOT" || true
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
