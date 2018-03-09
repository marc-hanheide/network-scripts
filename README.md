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


