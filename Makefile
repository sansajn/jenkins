image:
	# TODO: pull always do an update in case docker:dind installed which we do not want
	docker image pull docker:dind

	docker build -t myjenkins-blueocean:2.387.1-1 .	

start:
	# container always removed after it is stopped by `--rm`
	docker run --name jenkins-docker --rm --detach \
		--privileged --network jenkins --network-alias docker \
		--env DOCKER_TLS_CERTDIR=/certs \
		--volume jenkins-docker-certs:/certs/client \
		--volume jenkins-data:/var/jenkins_home \
		--publish 2376:2376 \
		docker:dind --storage-driver overlay2

	docker run --name jenkins-blueocean --restart=on-failure --detach \
		--network jenkins --env DOCKER_HOST=tcp://docker:2376 \
		--env DOCKER_CERT_PATH=/certs/client --env DOCKER_TLS_VERIFY=1 \
		--publish 8080:8080 --publish 50000:50000 \
		--volume jenkins-data:/var/jenkins_home \
		--volume jenkins-docker-certs:/certs/client:ro \
		myjenkins-blueocean:2.387.1-1 \
	|| \
	docker start jenkins-blueocean

stop:
	- docker stop jenkins-blueocean
	- docker stop jenkins-docker

logs:
	docker logs jenkins-blueocean

.PHONY: image start stop logs
