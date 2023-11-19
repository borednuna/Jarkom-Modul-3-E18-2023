#NOMOR1
#install dhcp-relay di route pada bashrc
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE -s 10.8.0.0/16
cat /etc/resolv.conf
apt-get update
echo "" | apt-get install isc-dhcp-relay -y

#lakukan konfigurasi berikut
echo"# Defaults for isc-dhcp-relay initscript
# sourced by /etc/init.d/isc-dhcp-relay
# installed at /etc/default/isc-dhcp-relay by the maintainer scripts

#
# This is a POSIX shell fragment
#

# What servers should the DHCP relay forward requests to?
SERVERS="192.215.1.1"

# On what interfaces should the DHCP relay (dhrelay) serve DHCP requests?
INTERFACES="eth1 eth2 eth3 eth4"
# Additional options that are passed to the DHCP relay daemon?
OPTIONS="""

service isc-dhcp-relay restart
