#!/usr/bin/env bash

## Color Setting
echo=echo
for cmd in echo /bin/echo; do
  $cmd >/dev/null 2>&1 || continue
  if ! $cmd -e "" | grep -qE '^-e'; then
    echo=$cmd
    break
  fi
done
CSI=$($echo -e "\033[")
CEND="${CSI}0m"
CDGREEN="${CSI}32m"
CRED="${CSI}1;31m"
CGREEN="${CSI}1;32m"
CYELLOW="${CSI}1;33m"
CBLUE="${CSI}1;34m"
CMAGENTA="${CSI}1;35m"
CCYAN="${CSI}1;36m"
CSUCCESS="$CDGREEN"
CFAILURE="$CRED"
CQUESTION="$CMAGENTA"
CWARNING="$CYELLOW"
CMSG="$CCYAN"

#Test The Color
#echo -e "${CDGREEN} A ${CEND}"
#echo -e "${CGREEN} A ${CEND}"
#echo -e "${CRED} A ${CEND}"
#echo -e "${CYELLOW} A ${CEND}"
#echo -e "${CBLUE} A ${CEND}"
#echo -e "${CSUCCESS} A ${CEND}"
#echo -e "${CFAILURE} A ${CEND}"
#echo -e "${CWARNING} A ${CEND}"
#echo -e "${CMSG} A ${CEND}"
#echo -e "${CQUESTION} A ${CEND}"


## OS Detect
if [ -e "/usr/bin/yum" ]; then
  PM=yum
  if [ -e /etc/yum.repos.d/CentOS-Base.repo ] && grep -Eqi "release 6." /etc/redhat-release; then
    sed -i "s@centos/\$releasever@centos-vault/6.10@g" /etc/yum.repos.d/CentOS-Base.repo
    sed -i 's@centos/RPM-GPG@centos-vault/RPM-GPG@g' /etc/yum.repos.d/CentOS-Base.repo
    [ -e /etc/yum.repos.d/epel.repo ] && rm -f /etc/yum.repos.d/epel.repo
  fi
  command -v lsb_release >/dev/null 2>&1 || { [ -e "/etc/euleros-release" ] && yum -y install euleros-lsb || yum -y install redhat-lsb-core; clear; }
fi
command -v lsb_release >/dev/null 2>&1 || { echo "${CFAILURE}${PM} source failed! ${CEND}"; kill -9 $$; }

# Detect System Bit
if [ "$(getconf WORD_BIT)" == "32" ] && [ "$(getconf LONG_BIT)" == "64" ]; then
  OS_BIT=64
else
  OS_BIT=32
fi
THREAD=$(grep 'processor' /proc/cpuinfo | sort -u | wc -l)

get_char() {
  SAVEDSTTY=`stty -g`
  stty -echo
  stty cbreak
  dd if=/dev/tty bs=1 count=1 2> /dev/null
  stty -raw
  stty echo
  stty $SAVEDSTTY
}

version() {
  echo "version: 2.0"
  echo "update date: 2021-05-21"
}

show_help() {
  version
  echo "
  Usage: $0  command ...[parameters]....
  --help, -h                  Show this help message
  --version, -v               Show version info
  --node_type [1-2]           Select Node type
  --nginx_option [1-3]        Install Nginx server version
  --pureftpd                  Install Pure-Ftpd
  --redis                     Install Redis
  --ssh_port [No.]            SSH port
  --firewalld                 Enable Firewalld
  --reboot                    Restart the server after installation
  "
}
