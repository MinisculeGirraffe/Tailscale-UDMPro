
## configuration variables:
VLAN=0
IPV4_IP="10.1.10.2"
IPV4_GW="10.1.10.1/24"
IPV6_IP="2600:1700:eec0:7310::2"
IPV6_GW="2600:1700:eec0:7310::1/64"

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

# Add Tailscale IP Routes via Container
ip route add 100.64.0.0/10 via ${IPV4_IP} dev br${VLAN}.mac
ip -6 route add fd7a:115c:a1e0:ab12:4843::/80 via ${IPV6_IP}

#Add routes from other subnet routers
ip route add 10.2.0.0/16 via ${IPV4_IP}
ip -6 route add 2600:1f16:116:3b00::/56 via ${IPV6_IP}

#start container & tailscale 
docker start tailscaled
docker exec tailscaled tailscale up --hostname=UDM-Pro --accept-routes=true --advertise-routes=10.1.0.0/16,2600:1700:eec0:7310::/60



