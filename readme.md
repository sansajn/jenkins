# About

The repository serves as a description to run Jenkins in docker container with aim to build C++ projects in a docker containers.

The solution is based on [Installing Jenkins/Docker](https://www.jenkins.io/doc/book/installing/docker/) article (with *docker:dind*).


**Contents**
- [ToDo](#todo)
- [Initial setup](#initial-setup)
- [Sample C++ Jenkins job](#sample-c-jenkins-job)
- [Enable docker pipeline](#enable-docker-pipeline)
- [Manual setup](#manual-setup)


## ToDo:
- docker compose for jenkins:dind based setup

## Initial setup

To build Jenkins and dind docker image run

```bash
make image
```

command. After that both containers Jenkins and dind can be run with

```bash
make start
```

command which runs `jenkins-docker` and `jenkins-blueocean` containrs, see

```console
$ docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS         PORTS                                                                                      NAMES
b9444211d8fc   docker:dind                     "dockerd-entrypoint.…"   9 minutes ago    Up 9 minutes   2375/tcp, 0.0.0.0:2376->2376/tcp, :::2376->2376/tcp                                        jenkins-docker
fbc20b640af4   myjenkins-blueocean:2.387.1-1   "/usr/bin/tini -- /u…"   53 minutes ago   Up 9 minutes   0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:50000->50000/tcp, :::50000->50000/tcp   jenkins-blueocean
```

command output.

After `make start` jenkins is available on `localhost:8080` address from the browser.

Jenkins logs can be shown by

```bash
make logs
```

command e.g. to check first login token for Jenkins initial setup.

Jenkins generated content is stored in `jenkins-data` docker volume, see

```console
$ docker volume ls
DRIVER    VOLUME NAME
local     jenkins-home
```

so it is available also after `jenkins-blueocean` container is removed (good for image updates).


## Sample C++ Jenkins job

Create *Multibranch Pipeline* item with a name `sample_cmake_ctest`. In *General* section set *Display Name* to `cmake_sample_ctest`, *Description* to *CMake CTest sample with docker and Jenkins integration.*  

Click to *Add source* button in *Branch Sources* section and pick *Git*. Set *Project Repository* to `https://github.com/sansajn/sample_cmake_ctest.git`, then in *Discover branches* click to *Add* and pick *Filter by name (with wildcards)* and set to `main`.

> **note**: `sample_cmake_ctest` is public repository so we do not need to set any credentials there

(Optional) In *Scan Multibranch Pipeline Triggers* section check *Periodically if not otherwise run* checkbox and set to 1 hour.

Click to *Save* button.

> TODO: Describe what should we see in Jenkins after this step ...

After scanning repository is done we should start to see `main` branch in the `cmake_sample_ctest`'s job list of branches.

We can click to `main` to open the branch and build it by clickind to *Build Now* button from left side menu.

## Enable docker pipeline

> **note**: it looks like that docker support plugins are installed by default

In order to execute docker pipelines e.g.

```Jenkinsfile
pipeline {
    agent {
        docker { image 'node:16.13.1-alpine' }
    }
    stages {
        stage('Test') {
            steps {
                sh 'node --version'
            }
        }
    }
}
```

install [Docker](https://plugins.jenkins.io/docker-plugin/) and [Docker Pipeline](https://plugins.jenkins.io/docker-workflow/) plugins.


## Manual setup

The section serves as a manual step-by-step tutorial to setup Jenkins setup.

1. Create dedicated network for jenkins setup by

```bash
docker network create jenkins
```

command. On my current system `network create` looks this way

```console
$ docker network create jenkins
6499f3c3d3d4a9d137f390000733c12f7ed6782bba887728cd1e9e4eb0e6ade9
$ docker network ls
NETWORK ID     NAME      DRIVER    SCOPE
7643f1e47f92   bridge    bridge    local
e07c77eb91ee   host      host      local
6499f3c3d3d4   jenkins   bridge    local
aa9863e8d039   none      null      local
```

2. Pull docker:dind image by

```bash
docker image pull docker:dind
```

command.

> check by `docker images` command docker:dind installed

3. Run docker:dind by

```bash
docker run --name jenkins-docker --rm --detach \
  --privileged --network jenkins --network-alias docker \
  --env DOCKER_TLS_CERTDIR=/certs \
  --volume jenkins-docker-certs:/certs/client \
  --volume jenkins-data:/var/jenkins_home \
  --publish 2376:2376 \
  docker:dind --storage-driver overlay2
```

> `--priviledged` mode may be relaxed by newer linux kernels, try it

where 

`--network-alias docker`: Makes the Docker in Docker container available as the hostname docker within the jenkins network.

`--env DOCKER_TLS_CERTDIR=/certs`: Use TLS certificates from `/certs` directory inside container.

`--volume jenkins-docker-certs:/certs/client`: Maps the `/certs/client` directory inside the container to a Docker volume named `jenkins-docker-certs` as created above.

> use `docker volume ls` command to see named volumes

`--volume jenkins-data:/var/jenkins_home`: Maps the `/var/jenkins_home` directory inside the container to the Docker volume named `jenkins-data`. This will allow for other Docker containers controlled by this Docker container’s Docker daemon to mount data from Jenkins.

`--publish 2376:2376`: (Optional) Exposes the Docker daemon port on the host machine. This is useful for executing docker commands on the host machine to control this inner Docker daemon.

`--storage-driver overlay2`: The storage driver for the Docker volume.

> is this mandatory?

On my current system after `docker run`, following `fa0faa71986d` container is running

```console
$ docker ps -a
CONTAINER ID   IMAGE                   COMMAND                   CREATED         STATUS                     PORTS                                                                                      NAMES
fa0faa71986d   docker:dind             "dockerd-entrypoint.…"    9 seconds ago   Up 8 seconds               2375/tcp, 0.0.0.0:2376->2376/tcp, :::2376->2376/tcp                                        jenkins-docker
```

4. Customize official Jenkins DOcker image this way

```Dockerfile
FROM jenkins/jenkins:2.387.1
USER root
RUN apt-get update && apt-get install -y lsb-release
RUN curl -fsSLo /usr/share/keyrings/docker-archive-keyring.asc \
  https://download.docker.com/linux/debian/gpg
RUN echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/usr/share/keyrings/docker-archive-keyring.asc] \
  https://download.docker.com/linux/debian \
  $(lsb_release -cs) stable" > /etc/apt/sources.list.d/docker.list
RUN apt-get update && apt-get install -y docker-ce-cli

# sample project support
RUN apt-get update && apt-get install -y make git

USER jenkins
RUN jenkins-plugin-cli --plugins "blueocean docker-workflow"
```

> TODO: what is "blueocean docker-workflow"?

> **note**: 2.387.1 is current Jenkins TLS version (4.4.2023)

build with

```bash
docker build -t myjenkins-blueocean:2.387.1-1 .
```

command. Check result with

```console
$ docker images
REPOSITORY                   TAG              IMAGE ID       CREATED              SIZE
myjenkins-blueocean          2.387.1-1        aa52da2b78ac   About a minute ago   790MB
```

command.

5. Run our customized myjenkins-blueocean:2.387.1-1 image as a container by

```bash
docker run --name jenkins-blueocean --restart=on-failure --detach \
  --network jenkins --env DOCKER_HOST=tcp://docker:2376 \
  --env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
  --publish 8080:8080 --publish 50000:50000 \
  --volume jenkins-data:/var/jenkins_home \
  --volume jenkins-docker-certs:/certs/client:ro \
  myjenkins-blueocean:2.387.1-1
```

check two containers are running with

```console
$ docker ps
CONTAINER ID   IMAGE                           COMMAND                  CREATED          STATUS          PORTS                                                                                      NAMES
695fab915bba   myjenkins-blueocean:2.387.1-1   "/usr/bin/tini -- /u…"   5 seconds ago    Up 4 seconds    0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:50000->50000/tcp, :::50000->50000/tcp   jenkins-blueocean
fa0faa71986d   docker:dind                     "dockerd-entrypoint.…"   17 minutes ago   Up 17 minutes   2375/tcp, 0.0.0.0:2376->2376/tcp, :::2376->2376/tcp                                        jenkins-docker
```

command.

6. Login to running Jenkins instance at `loacalhost:8080` address.

> use `docker logs jenkins-blueocean` to see installation password used for the first login
