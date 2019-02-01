#!/bin/bash

#tracker_url="https://script.google.com/macros/s/AKfycby3hVerD9ysczkdHsgjOYrCalY7R_Kho37iKfhO2LHLy-qb5vqq/exec"
tracker_url="https://lcas.lincoln.ac.uk/hosttrack/ping"

default_hostname=`hostname`

while getopts "hvu:n:" opt; do
  case ${opt} in
    h ) 
      echo "Usage:"
      echo " -h      Display this help message."
      echo " -n name set name (default: $default_hostname)" 
      exit 0
      ;;
    v )
      VERBOSE=1
      ;;
    n )
      default_hostname="$OPTARG"
      ;;
    u )
      tracker_url="$OPTARG"
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
  default_ip=`ip addr show dev "$default_iface" | grep "inet " | sed 's@ *inet \([0-9\.]*\).*@\1@'`
fi

update_date="`date| sed 's/ /%20/g'`"

if which nmap > /dev/null 2>&1; then
  ports=`nmap $default_ip | grep " open" | cut -f1 -d"/" | tr "\n" ","`
else
  ports="no%20nmap"
fi

if which dig > /dev/null 2>&1; then
  public_ip=`dig TXT +time=1 +tries=1 +short o-o.myaddr.l.google.com @ns1.google.com | awk -F'"' '{ print $2}'`
else
  public_ip="no%20dig"
fi



params="name=$default_hostname&ip=$default_ip&comment=iface%20$default_iface%20ports:%20$ports&updated=$update_date&public_ip=$public_ip"
fullurl="$tracker_url?$params"


QUIET="-s"

if [ "$VERBOSE" ]; then
  echo "system:        $system"
	echo "default_iface: $default_iface"
	echo "default_ip:    $default_ip"
  echo "public_ ip:    $public_ip"
	echo "tracker_url:   $tracker_url"
	echo "fullurl:       $fullurl"
  echo "ports:         $ports"
	QUIET=""
fi

curl $QUIET -o /dev/null "$fullurl"
