#!/bin/sh

PATH="/bin:/usr/bin:/sbin:/usr/sbin"

if dpkg -l apache2 >/dev/null 2>&1; then
  DAEMON="apache2"
  cp apache/oggz-chop.conf /etc/apache2/conf.d/
elif dpkg -l apache >/dev/null 2>&1; then
  DAEMON="apache"
  cp apache/oggz-chop.conf /etc/apache/conf.d
else
  echo 1>&2 "Error: Neither apache2 or apache are installed"
  exit 1
fi

invoke-rc.d $DAEMON reload || true
