# Tailscale-UDMPro

## A Guide to running Tailscale on a UDM(Pro)


### Prerequisites

- Install [On-Boot scripts](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)

- Update [CNI plugins](https://github.com/boostchicken/udm-utilities/blob/master/cni-plugins/05-install-cni-plugins.sh)

- Create macvtap network.conflist for the container in `/mnt/data/podman/cni`

#### Configure Network interfaces
 
The on-boot script attatched to this repo can be used as an example. Due to the host networking stack not being compatible with Tailscale, routes will have to be configured manually. The container is given a local IP address and any Tailscale IP's or subnet routes can be pointed to the container via `ip route`



#### Create Tailscale Image
Build Tailscale for ARM64

This requires Go which can be downloaded for arm64 [here](https://golang.org/dl/) and symlinked to `/usr/bin/`

Download the latest release from the [Tailscale Github](https://github.com/tailscale/tailscale/releases/) and build the container

```shell
curl 'https://github.com/tailscale/tailscale/archive/refs/tags/v1.10.2.tar.gz' -o tailscale.tar.gz
tar -xzvf tailscale.tar.gz 
cd tailscale
docker build
```

##### Create Container
 Persistent storage is needed to store the logs & state file.  Tailscale will create it's own folder in the path you specify.

 I use `/mnt/data/docker` as the base for all my containers. The example below will store the files in `/mnt/data/docker/tailscale`

``` shell
docker run -d --name=tailscaled \
--cap-add=NET_ADMIN \
--cap-add=SYS_MODULE \
-v /mnt/data/docker:/var/lib \
-v /dev/net/tun:/dev/net/tun \
--network=tailscale \
--privileged \
tailscale:tailscale tailscaled
```

##### Start Container

``` shell
docker start tailscaled
docker exec tailscaled tailscale up \
--hostname=UDM-Pro \
--accept-routes=true \
--advertise-routes=10.1.0.0/16,2600:1700:eec0:7310::/60
```
