# docker-openocd
The example for setup OpenOCD which running in Docker container.

Initial Date:

	2020/11/04

Version:

	Alpine Linux: 3.14
	OpenOCD: 0.11.0

Documentation:


Docker Hub:

><https://hub.docker.com/r/changhsinglee/alpine-openocd>

GitHub (source):

><https://github.com/ChangHsingLee/docker-openocd.git>

# Install docker engine in Ubuntu distro
Refer to <https://docs.docker.com/engine/install/ubuntu/>
1. remove old versions of Docker
2. Update the apt package index and install packages to allow apt to use a repository over HTTPS
```shell
sudo apt-get update && \
sudo apt-get install \
     apt-transport-https \
     ca-certificates \
     curl \
     gnupg \
     lsb-release
```
3. Add Docker's official GPG key:
```shell
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
```
4. Use the following command to set up the stable repository
```shell
echo \
"deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] 		  https://download.docker.com/linux/ubuntu \
$(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
5. Update the apt package index, and install the latest version of Docker Engine and containerd:
```shell
sudo apt-get update && \
sudo apt-get install docker-ce docker-ce-cli containerd.io
```

# Installation
## Get docker image (download or create)
- Download docker image\
docker pull changhsinglee/alpine-openocd
- Create docker image\
You should get source code from [GitHub](https://github.com/ChangHsingLee/docker-openocd) and put it into directory '$SRC_DIR'
```shell
SRC_DIR=$HOME/workspace/docker-openocd; \
DOCKER_IMG_NAME="changhsinglee/alpine-openocd:latest"; \
cd $SRC_DIR && docker build -t $DOCKER_IMG_NAME .
```
> OR\
You can load the docker image "[alpine-openocd-dockerImg.tar.bz2](https://github.com/ChangHsingLee/backup-dockerImg/blob/main/alpine-openocd-dockerImg.tar.bz2)" which be saved/tested.
```shell
bzip2 -dcv alpine-openocd-dockerImg.tar.bz2 | docker load
```
> The image is saved/compressed by below command:
```shell
docker save changhsinglee/alpine-openocd:latest | bzip2 -9vz > alpine-openocd-dockerImg.tar.bz2
```

## Prepare docker volume (Optional)
It uses to store firmware image, scripts and anything needed by using In-Circuit Debugger (ICD).
```shell
VOLUME_TOPDIR=$HOME/workspace/dockerVolumes/alpine-openocd; \
mkdir -p $VOLUME_TOPDIR/
```
# Start Container
## Start OpenOCCD
> DOCKER_IMG_NAME="changhsinglee/alpine-openocd:latest"; \\\
CONTAINER_NAME=openocd; \\\
VOLUME_TOPDIR=$HOME/workspace/dockerVolumes/alpine-openocd; \\\
docker run -it \\\
--name $CONTAINER_NAME \\\
-v $VOLUME_TOPDIR:/srv \\\
**--privileged** --rm $DOCKER_IMG_NAME \\\
openocd -s /srv [*options*]

## Start GDB to connect to OpenOCD for debugging
> CONTAINER_NAME=openocd; \\\
docker exec -it $CONTAINER_NAME gdb-multiarch
