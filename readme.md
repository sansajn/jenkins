# About

## Initial setup

To build Jenkins docker image run

```bash
make image
```

command. After that container can be run with

```bash
make start
```

command which will run jenkins docker as `jenkins_container` container, see result of `socker ps -a` command

```conosle
$ docker ps -a
CONTAINER ID   IMAGE             COMMAND                  CREATED          STATUS                      PORTS                                                                                      NAMES
4fc2d354c160   jenkins:1.0       "/usr/bin/tini -- /u…"   16 seconds ago   Up 15 seconds               0.0.0.0:8080->8080/tcp, :::8080->8080/tcp, 0.0.0.0:50000->50000/tcp, :::50000->50000/tcp   jenkins_container
```

After `make start` jenkins is available on `localhost:8000` address from the browser.

Jenkins logs can be shown by

```bash
docker logs jenkins_container
```

command e.g. to check first login token.

Jenkins generated content is stored in `jenkins_home` docker volume

```console
$ docker volume ls
DRIVER    VOLUME NAME
local     jenkins_home
```

so it is available also after `jenkins_container` container is removed (good for image updates).

## Sample C++ Jenkins job

Create *Multibranch Pipeline* item with a name `sample_cmake_ctest`. In *General* section set *Display Name* to `cmake_sample_ctest`, *Description* to *CMake CTest sample with docker and Jenkins integration.*  

Click to *Add source* button in *Branch Sources* section and pick *Git*. Set *Project Repository* to `https://github.com/sansajn/sample_cmake_ctest.git`, then in *Discover branches* click to *Add* and pick *Filter by name (with wildcards)* and set to `main`.

> **note**: `sample_cmake_ctest` is public repository so we do not need to set any credentials there

(Optional) In *Scan Multibranch Pipeline Triggers* section check *Periodically if not itherwise run* checkbox and set to 1 hour.

Click to *Save* button.

# Issues

- `/bin/sh: 1: docker: not found` in case of Sample C++ Jenkins job ...

> Q1: Can we run docker build from inside docker Jenkins?

no we can not, Jenkins complains with `/bin/sh: 1: docker: not found`
