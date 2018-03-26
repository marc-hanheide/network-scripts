#!/bin/bash


default_hostname=`hostname`

while getopts "hv" opt; do
  case ${opt} in
    h ) 
      echo "Usage:"
      echo " -h      Display this help message."
      exit 0
      ;;
    v )
      VERBOSE=1
      ;;
    \? )
      exit 1
      ;;
  esac
done

system="`uname`"
if [ "$system" = "Darwin" ]; then
  default_iface=`route get default | grep interface| sed 's/ *interface: \(.*\)$/\1/'`
  default_ip=`ifconfig $default_iface | grep "inet " | sed 's@^.*inet \([0-9\.]*\).*@\1@'`
else
  default_iface=$(awk '$2 == 00000000 { print $1 }' /proc/net/route)
  default_ip=`ip addr show dev "$default_iface" 2>/dev/null | grep "inet " | sed 's@ *inet \([0-9\.]*\).*@\1@'`
fi

update_date="`date| sed 's/ /%20/g'`"


if which dig > /dev/null 2>&1; then
  public_ip=`dig TXT +short o-o.myaddr.l.google.com @ns1.google.com 2>/dev/null| awk -F'"' '{ print $2}'`
else
  public_ip=""
fi

physical_wifi=`/usr/sbin/rfkill list | grep -i wireless | head -n1|cut -f1 -d:`

if [ "$VERBOSE" ]; then
  echo "system:        $system"
  echo "default_iface: $default_iface"
  echo "default_ip:    $default_ip"
  echo "public_ip:     $public_ip"
  echo "pysical_wifi:  $physical_wifi"
fi

if [ -z "$default_ip" ]; then
  if [ "$VERBOSE" ]; then
    echo "lost connectivity, power-cycle wifi network"
  else
    echo "lost connectivity, power-cycle wifi network" | logger
  fi
  /usr/sbin/rfkill block "$physical_wifi"  2>&1 | logger
  sleep 5
  /usr/sbin/rfkill unblock "$physical_wifi" 2>&1 | logger
  sleep 5
  /usr/bin/nmcli d wifi rescan
fi
