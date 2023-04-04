# About

This directory contains my previous attempt to run Jenkins in a Docker container only based on Jenkins docker see [Official Jenkins Docker image](https://github.com/jenkinsci/docker/blob/master/README.md).

The issue was to build project as docker containers within the Jenkins docker container which was done via host shared docker socket. We currently preffer dind setup described in parent directory.


**Contents**
- [Initial setup](#initial-setup)
- [Sample C++ Jenkins job](#sample-c-jenkins-job)
- [Enable docker pipeline](#enable-docker-pipeline)
- [Issues](#issues)


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

After `make start` jenkins is available on `localhost:8080` address from the browser.

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

(Optional) In *Scan Multibranch Pipeline Triggers* section check *Periodically if not otherwise run* checkbox and set to 1 hour.

Click to *Save* button.

> TODO: Describe what should we see in Jenkins after this step ...

After scanning repository is done we should start to see `main` branch in the `cmake_sample_ctest`'s job list of branches.

We can click to `main` to open the branch and build it by clickind to *Build Now* button from left side menu.

## Enable docker pipeline

In order to execute docker pipelines e.g.

```
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


## Issues

Some issues I was facing during the learning process.

- Docker host accces is not working with Jenkins user (only root)and that makes trouble in case docker builds e.g. `sample_cmake_ctest`


> Q1: Can we execute docker build from inside docker Jenkins?

No we can't, Jenkins complains with `/bin/sh: 1: docker: not found`.

> Q2: Can we use docker agent in a `Jenkinsfile` from inside a docker Jenkins?

No we can't by default.

Using docker agent from from following pipeline

```
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

> taken from [Using Docker with Pipeline](https://www.jenkins.io/doc/book/pipeline/docker/) article

results to 

```
org.codehaus.groovy.control.MultipleCompilationErrorsException: startup failed:
WorkflowScript: 3: Invalid agent type "docker" specified. Must be one of [any, label, none] @ line 3, column 9.
           docker { image 'node:16.13.1-alpine' }
           ^
```

Jenkins complain.

To solve the issue install [Docker](https://plugins.jenkins.io/docker-plugin/) and [Docker Pipeline](https://plugins.jenkins.io/docker-workflow/) plugins.
