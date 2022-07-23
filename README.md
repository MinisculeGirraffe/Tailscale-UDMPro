# Tailscale-UDMPro

## A Guide to running Tailscale on a UDM(Pro)

### Prerequisites

- Install [On-Boot scripts](https://github.com/boostchicken/udm-utilities/tree/master/on-boot-script)

- Update [CNI plugins](https://github.com/boostchicken/udm-utilities/blob/master/cni-plugins/05-install-cni-plugins.sh)

#### Configure Network interfaces

The on-boot script attatched to this repo can be used as an example. Due to the host networking stack not being compatible with Tailscale, routes will have to be configured manually. The container is given a local IP address and any Tailscale IP's or subnet routes can be pointed to the container via `ip route`

The container is giving a local IP by creating a macvtap network `tailscale.conflist` for the container in `/mnt/data/podman/cni`.  See the example `tailscale.conflist` file in this repository

Replace the IP values for your environment in `tailscale.conflist` and `06-tailscale.sh`.

#### Create Tailscale Image
Tailscale provided ARM64 docker images now. You can pull the latest docker image using the following command

``` shell
docker pull tailscale/tailscale
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
tailscale/tailscale tailscaled
```

##### Start Container

To start the container, execute the sh file you have updated with the values for your environment. 
