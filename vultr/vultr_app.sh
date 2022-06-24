#!/bin/bash

###################################################################
## Vultr Marketplace Helper Functions

function error_detect_on() {
    set -euo pipefail
}

function error_detect_off() {
    set +euo pipefail
}

function enable_verbose_commands() {
    set -x pipefail
}

function disable_verbose_commands() {
    set +x pipefail
}

function get_hostname() {
    HOSTNAME=$(curl --fail -s "http://169.254.169.254/latest/meta-data/hostname")
    echo "${HOSTNAME}"
}

function get_userdata() {
    USERDATA=$(curl --fail -s "http://169.254.169.254/latest/user-data")
    echo "${USERDATA}"
}

function get_sshkeys() {
    KEYS=$(curl --fail -s "http://169.254.169.254/current/ssh-keys")
    echo "${KEYS}"
}

function get_var() {
    local val="$(curl --fail -s -H "Metadata-Token: vultr" http://169.254.169.254/v1/internal/app-${1} 2>/dev/null)"

    local __result=$1
    eval $__result="'${val}'"
}

function get_ip
{
    local val="$(curl --fail -s -H "Metadata-Token: vultr" http://169.254.169.254/v1/internal/meta-data/meta-data/public-ipv4 2>/dev/null)"

    local __result=$1
    eval $__result="'${val}'"
}

function wait_on_apt_lock() {
    DPKG_ID=$(lsof -t /var/lib/dpkg/lock) || true
    APT_ID=$(lsof -t /var/lib/apt/lists/lock) || true
    CACHE_ID=$(lsof -t /var/cache/apt/archives/lock) || true
    until [[ "${DPKG_ID}${APT_ID}${CACHE_ID}" == "" ]]
    do
        echo "Waiting for apt lock held by: [${DPKG_ID}-${APT_ID}-${CACHE_ID}]"
        sleep 3
        DPKG_ID=$(lsof -t /var/lib/dpkg/lock) || true
        APT_ID=$(lsof -t /var/lib/apt/lists/lock) || true
        CACHE_ID=$(lsof -t /var/cache/apt/archives/lock) || true
    done
    echo "/var/lib/dpkg/lock is unlocked."
    echo "/var/lib/apt/lists/lock is unlocked."
    echo "/var/cache/apt/archives/lock is unlocked."
}

function apt_safe() {
    wait_on_apt_lock
    apt install -y $@
}

function apt_update_safe() {
    wait_on_apt_lock
    apt update -y
}

function apt_upgrade_safe() {
    wait_on_apt_lock
    DEBIAN_FRONTEND=noninteractive apt upgrade -y
}

function apt_remove_safe() {
    wait_on_apt_lock
    apt remove -y $@ --auto-remove
}

function apt_clean_safe() {
    wait_on_apt_lock
    apt autoremove -y

    wait_on_apt_lock
    apt autoclean -y
}

function update_and_clean_packages() {

    # RHEL/CentOS
    if [[ -f /etc/redhat-release ]]; then
        yum update -y
        yum clean all
    # Ubuntu / Debian
    elif [[ "$(grep -c "debian" /etc/os-release)" != "0" ]]; then
        apt_update_safe
        apt_upgrade_safe
        apt_clean_safe
    fi
}

function set_vultr_kernel_option() {
    # RHEL/CentOS
    if [[ -f /etc/redhat-release ]]; then
        /sbin/grubby --update-kernel=ALL --args vultr
    # Ubuntu / Debian
    elif [[ "$(grep -c "ID=debian" /etc/os-release)" != "0" ]]; then
        sed -i "/^GRUB_CMDLINE_LINUX_DEFAULT=/ s/\"$/ vultr\"/" /etc/default/grub
        update-grub
    fi
}

function install_cloud_init() {

    if [ -x "$(command -v cloud-init)" ]; then
        echo "cloud-init is already installed."
        return
    fi

    update_and_clean_packages

    if [[ -f /etc/redhat-release ]]; then
        BUILD="rhel"
        DIST="rpm"
    fi

    if [[ "$(grep -c "ID=ubuntu" /etc/os-release)" != "0" ]]; then
        BUILD="universal"
        DIST="deb";
    fi

    if [[ "$(grep -c "ID=debian" /etc/os-release)" != "0" ]]; then
        BUILD="debian"
        DIST="deb";
    fi

    if [[ "${DIST}" == "" ]]; then
        echo "Undetected OS, please install from source!"
        exit 255
    fi

    RELEASE=$1

    if [[ "${RELEASE}" == "" ]]; then
        RELEASE="latest"
    fi

    if [[ "${RELEASE}" != "latest" ]] && [[ "${RELEASE}" != "nightly" ]]; then
        echo "${RELEASE} is an invalid release option. Allowed: latest, nightly"
        exit 255
    fi

    # Lets remove all traces of previously installed cloud-init
    # Ubuntu installs have proven problematic with their left over
    # configs for the installer in recent versions
    cleanup_cloudinit || true

    wget https://ewr1.vultrobjects.com/cloud_init_beta/cloud-init_${BUILD}_${RELEASE}.${DIST} -O /tmp/cloud-init_${BUILD}_${RELEASE}.${DIST}

    if [[ "${DIST}" == "rpm" ]]; then
        yum install -y /tmp/cloud-init_${BUILD}_${RELEASE}.${DIST}
    elif [[ "${DIST}" == "deb" ]]; then
        apt_safe /tmp/cloud-init_${BUILD}_${RELEASE}.${DIST}
    fi

    rm -f /tmp/cloud-init_${BUILD}_${RELEASE}.${DIST}
}

function cleanup_cloudinit() {
    rm -rf /etc/cloud
    rm -rf /etc/systemd/system/cloud-init.target.wants/*
    rm -rf /usr/src/cloud*
    rm -rf /usr/local/bin/cloud*
    rm -rf /usr/bin/cloud*
    rm -rf /usr/lib/cloud*
    rm -rf /usr/local/bin/cloud*
    rm -rf /lib/systemd/system/cloud*
    rm -rf /var/lib/cloud
    rm -rf /var/log/cloud*
    rm -rf /run/cloud-init
}

function clean_tmp() {
    mkdir -p /tmp
    chmod 1777 /tmp
    rm -rf /tmp/*
    rm -rf /var/tmp/*
}

function clean_keys() {
    rm -f /root/.ssh/authorized_keys /etc/ssh/*key*
    touch /etc/ssh/revoked_keys
    chmod 600 /etc/ssh/revoked_keys
}

function clean_logs() {
    find /var/log -mtime -1 -type f -exec truncate -s 0 {} \;
    rm -rf /var/log/*.gz
    rm -rf /var/log/*.[0-9]
    rm -rf /var/log/*.log
    rm -rf /var/log/lastlog
    rm -rf /var/log/wtmp
    echo "" >/var/log/auth.log
}

function clean_history() {
    history -c
    echo "" > /root/.bash_history
    unset HISTFILE
}

function clean_mloc() {
    /usr/bin/updatedb
}

function clean_random() {
    rm -f /var/lib/systemd/random-seed
}

function clean_machine_id() {
    rm -f /etc/machine-id
    touch /etc/machine-id
}

function clean_free_space() {
    dd if=/dev/zero of=/zerofile
    sync
    rm -f /zerofile
    sync
}

function trim_ssd() {
    fstrim /
}

function cleanup_marketplace_scripts() {
    rm -f /root/*.sh
}

function disable_network_manager() {
    ## Disable NetworkManager, replace with network-scripts
    systemctl stop NetworkManager
    systemctl disable NetworkManager
    sed -i 's/^ONBOOT.*/ONBOOT=yes/g' /etc/sysconfig/network-scripts/ifcfg-*
    sed -i 's/^NM_CONTROLLED.*/NM_CONTROLLED=no/g' /etc/sysconfig/network-scripts/ifcfg-*
    yum install -y network-scripts
}

function clean_system() {

    update_and_clean_packages
    set_vultr_kernel_option
    clean_tmp
    clean_keys
    clean_logs
    clean_history
    clean_random
    clean_machine_id

    clean_mloc || true
    clean_free_space || true
    trim_ssd || true

    cleanup_marketplace_scripts
}
