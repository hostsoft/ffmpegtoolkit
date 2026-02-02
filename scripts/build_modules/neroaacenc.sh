#!/usr/bin/env bash
# Nero AAC encoder (binary install from zip)

build_neroaacenc() {
    local name="neroaacenc"
    local srcdir="$BUILD_DIR/nero"
    mkdir -p "$srcdir"
    [[ ! -f "$DOWNLOADS_DIR/NeroDigitalAudio.zip" ]] && {
        log_info "[$name] Downloading NeroDigitalAudio.zip..."
        wget -q -O "$DOWNLOADS_DIR/NeroDigitalAudio.zip" \
            "http://techdata.mirror.gtcomm.net/sysadmin/ffmpeg-avs/NeroDigitalAudio.zip" || return 1
    }
    unzip -o "$DOWNLOADS_DIR/NeroDigitalAudio.zip" -d "$srcdir"
    install -D -m755 "$srcdir/linux/neroAacEnc" "$PREFIX/bin/neroAacEnc"
    install -D -m755 "$srcdir/linux/neroAacDec" "$PREFIX/bin/neroAacDec"
    rm -rf "$srcdir"
    touch "${BUILD_DIR}/.done_${name}"
}
