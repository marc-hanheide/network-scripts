#!/bin/bash

# this is designed to work only with the L-CAS vpn:

tmp_hosts=/tmp/hosts.$$
identifier="b53115cfd1313a60f2f46ab498a4961b"

# create tmp hosts without the vpn specific content
grep -v -F "$identifier" /etc/hosts > "$tmp_hosts"

curl https://lcas.lincoln.ac.uk/vpn/hosts.sh >> "$tmp_hosts"

cat "$tmp_hosts" > /etc/hosts

rm -f "$tmp_hosts"
