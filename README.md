# VPN

L-CAS runs a VPN server. All currently connected clients can be seen at https://lcas.lincoln.ac.uk/vpn/. 


## connect yourself to the VPN

1. Obtain an OpenVPN config file from the admin interface (if you can log in) or from your respective administrator, e.g. a file `HOSTNAME.ovpn`
1. install openvpn, if you haven't done so yet: `sudo apt-get install openvpn`
1. run `sudo openvpn HOSTNAME.ovpn` to initiate the connection, you will receive a VPN IP in the `172.31.0.0/22` network, e.g. `172.31.0.42`. This IP is cached and linked to your account. That also means you can only log in _once_ with your `HOSTNAME.ovpn` at any one time, but whereever you login in with that file, you get the same IP.

## add VPN hosts to `/etc/hosts`

The script [`vpn-hosts-update.sh`](https://raw.githubusercontent.com/marc-hanheide/network-scripts/master/vpn-hosts-update.sh) can be used to add all the VPN hosts to the `/etc/hosts` file (often needed to make ROS networks work). The following line does it automatically for you:

```
curl https://raw.githubusercontent.com/marc-hanheide/network-scripts/master/vpn-hosts-update.sh | sudo bash
```


# IP Tracker

corresponding google web app: https://script.google.com/a/macros/hanheide.net/d/119--OhuuKOKNCtl8mtx5YJBsQveA_PfxaUZRn-03nZwlzJYu_UAga_qo/edit?uiv=2&mid=ACjPJvE4i3X3zOB4SwJBD1fCPRVmDhstWvkrTsbobg13y0nx4JIPAzKuF19OrOs-2fXsyqq8ZdAdVxwt8TdyieGtWcTC_lsKKHKKlqU4aYmmIXNrr0pW-B29gt1EOZ24E08tW7CFNVBibw

`iptracker.sh` is to be used with this web app, and to be run in cron like this:

```
*/30 * * * * /path/to/file/iptracker.sh
```

(you may change `*/30` to `*/1` to update it every minute)

# ROS network

This script configures the ROS environment variables according to the route
to the ROS_MASTER. ROS_MASTER can either be defined as an evironment variable
itself or given as first argument to this script. The ROS_IP and ROS_HOSTNAME
are set according to the IP that is sitting on the route to this master. 
The ROS_MASTER_URI is also set, using port 11311. ROS_MASTER needs to be defined
as a numeric IP address, not a hostname.

E.g.: `source ./ros-network.sh 192.168.0.1` assuming the ROS master is at address `192.168.0.1`.


