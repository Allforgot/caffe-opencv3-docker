# caffe-opencv3-docker

Setting up caffe opencv3 cuda9 cudnn7 running environment with docker

## Getting Started

### Prerequisites

- Ubuntu 16.04

- nvidia drive >= 384.81

  Use `nvidia-smi` to check nvidia drive version

- docker

  1. remove old version docker

     ```bash
     $ sudo apt-get remove docker docker-engine docker.io
     ```

  2. install docker using apt

     ```bash
     $ sudo apt-get update
     $ sudo apt-get install apt-transport-https ca-certificates curl software-properties-common
     # use ustc source
     $ curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add -
     $ sudo add-apt-repository "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu $(lsb_release -cs) stable"
     # use official source
     # $ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
     # $ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
     $ sudo apt-get update
     $ sudo apt-get install docker-ce
     ```

  3. run docker ce

     ```bash
     $ sudo systemctl enable docker
     $ sudo systemctl start docker
     ```

  4. add docker user group

     ```bash
     $ sudo groupadd docker
     # add current user to group docker
     $ sudo usermod -aG docker $USER
     ```

  5. test docker

     ```bash
     $ docker run hello-world   
     
     Unable to find image 'hello-world:latest' locally
     latest: Pulling from library/hello-world
     1b930d010525: Pull complete 
     Digest: sha256:41a65640635299bab090f783209c1e3a3f11934cf7756b09cb2f1e02147c6ed8
     Status: Downloaded newer image for hello-world:latest
     
     Hello from Docker!
     This message shows that your installation appears to be working correctly.
     
     To generate this message, Docker took the following steps:
      1. The Docker client contacted the Docker daemon.
      2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
         (amd64)
      3. The Docker daemon created a new container from that image which runs the
         executable that produces the output you are currently reading.
      4. The Docker daemon streamed that output to the Docker client, which sent it
         to your terminal.
     
     To try something more ambitious, you can run an Ubuntu container with:
      $ docker run -it ubuntu bash
     
     Share images, automate workflows, and more with a free Docker ID:
      https://hub.docker.com/
     
     For more examples and ideas, visit:
      https://docs.docker.com/get-started/
     
     ```

- nvidia-docker

  ```bash
  # If you have nvidia-docker 1.0 installed: we need to remove it and all existing GPU containers
  $ docker volume ls -q -f driver=nvidia-docker | xargs -r -I{} -n1 docker ps -q -a -f volume={} | xargs -r docker rm -f
  $ sudo apt-get purge -y nvidia-docker
  
  # Add the package repositories
  $ curl -s -L https://nvidia.github.io/nvidia-docker/gpgkey | sudo apt-key add -
  $ distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
  $ curl -s -L https://nvidia.github.io/nvidia-docker/$distribution/nvidia-docker.list | sudo tee /etc/apt/sources.list.d/nvidia-docker.list
  $ sudo apt-get update
  
  # Install nvidia-docker2 and reload the Docker daemon configuration
  $ sudo apt-get install -y nvidia-docker2
  $ sudo pkill -SIGHUP dockerd
  
  # Test nvidia-smi with the latest official CUDA image
  $ nvidia-docker run --runtime=nvidia --rm nvidia/cuda:9.0-base nvidia-smi
  ```

### Installing

```bash
nvidia-docker build -t caffe-tensorflow:cuda9-cudnn7-py3 .
```

## Running the tests

```bash
$ nvidia-docker run -itd --name test caffe-tensorflow:cuda9-cudnn7-py3
$ nvidia-docker exec test /bin/bash
```

test the environment with python

```bash
$ python3
>>> import caffe
>>> import cv2
```

