#!/bin/sh

#configuration variables:
#The VLAN the tailscale container will be attached to.
VLAN=0

#The IPv4 address of the tailscale container.
IPV4_IP="<ADDR>"
IPV4_GW="<ADDR>/<CIDR>"

#The IPv6 address of the tailscale container.
IPV6_IP="<ADDRv6>"
IPV6_GW="<ADDRv6>/<CIDR>"

#The local routes you want to expose to tailscale
#Seperate with a "," for multiple routes
SUBNET_ROUTES="<ADDR>/<CIDR>,<ADDR>/<CIDR>"

#The tailscale ipv4 subnet is static to the CGNAT range
#https://tailscale.com/kb/1015/100.x-addresses/
TAILSCALE_NETV4="100.64.0.0/10"
#The Tailscale IPv6 Subnet range
#https://tailscale.com/kb/1033/ip-and-dns-addresses/#tailscale-ipv6-local-address-prefix
TAILSCALE_NETV6="fd7a:115c:a1e0:ab12::/64"

# set VLAN bridge promiscuous
ip link set br${VLAN} promisc on

# create macvlan bridge and add IPv4 IP
ip link add br${VLAN}.mac link br${VLAN} type macvlan mode bridge
ip addr add ${IPV4_GW} dev br${VLAN}.mac noprefixroute
ip -6 addr add ${IPV6_GW} dev br${VLAN}.mac noprefixroute


# set macvlan bridge promiscuous and bring it up
ip link set br${VLAN}.mac promisc on
ip link set br${VLAN}.mac up

# Add routes to container through macvlan bridge
ip route add ${IPV4_IP}/32 dev br${VLAN}.mac
ip -6 route add ${IPV6_IP}/128 dev br${VLAN}.mac

# Add Tailscale IP Routes via Container IP
ip route add ${TAILSCALE_NETV4} via ${IPV4_IP} dev br${VLAN}.mac
ip -6 route add ${TAILSCALE_NETV6} via ${IPV6_IP}

#Add routes from other subnet routers
ip route add 10.2.0.0/16 via ${IPV4_IP}
ip -6 route add 2600:1f16:116:3b00::/56 via ${IPV6_IP}

#Start Container
docker start tailscaled
#Enable IPv6 routing on container
docker exec tailscaled sysctl -w net.ipv6.conf.all.forwarding=1
#Enable the VPN
docker exec tailscaled tailscale up --hostname=UDM-Pro --accept-routes=true --advertise-routes=${SUBNET_ROUTES}



