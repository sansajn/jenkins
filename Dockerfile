# based on https://github.com/jenkinsci/docker/blob/master/README.md

FROM jenkins/jenkins:lts-jdk11

# if we want to install via apt
USER root
RUN apt-get update && apt-get install -y make

# drop back to the regular jenkins user - good practice
USER jenkins
