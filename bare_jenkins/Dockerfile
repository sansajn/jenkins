FROM jenkins/jenkins:lts

USER root

RUN apt-get update -qq \
	&& apt-get install -qqy \
		apt-transport-https \
		ca-certificates \
		curl \
		gnupg2 \
		software-properties-common \
		make \
		git

# install docker
RUN curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -
RUN add-apt-repository \
	"deb [arch=amd64] https://download.docker.com/linux/debian \
	$(lsb_release -cs) \
	stable"
RUN apt-get update  -qq \
	&& apt-get -y install docker-ce

RUN usermod -aG docker jenkins

# switch to jenkins user prevents docker to be run with *permission denied while trying to connect to the Docker daemon socket* complain
#USER jenkins
