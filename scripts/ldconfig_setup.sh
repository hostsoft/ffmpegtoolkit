#!/usr/bin/env bash
# Setup /etc/ld.so.conf.d/ffmpegtoolkit.conf and run ldconfig
# Must be run as root for writing to /etc/ld.so.conf.d/

LDCONF_FILE="/etc/ld.so.conf.d/ffmpegtoolkit.conf"

setup_ldconfig() {
    if [[ $EUID -ne 0 ]]; then
        log_warn "ldconfig setup requires root. Run: sudo $0 or use --ldconfig with build.sh"
        return 1
    fi
    log_info "Writing $LDCONF_FILE ..."
    cat > "$LDCONF_FILE" << EOF
/usr/local/lib
/usr/local/lib64
${PREFIX:-/opt/ffmpeg-toolkit}/lib
${PREFIX:-/opt/ffmpeg-toolkit}/lib64
EOF
    if [[ -d "${CUDA_HOME:-/usr/local/cuda}" ]]; then
        echo "${CUDA_HOME:-/usr/local/cuda}/lib64" >> "$LDCONF_FILE"
    fi
    log_info "Running ldconfig ..."
    ldconfig
}
