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


> Q1: Can we run docker build from Jenkins?