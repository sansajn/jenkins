HOSTNAME ?= jenkins
IMAGE_NAME ?= ${HOSTNAME}:1.2
CONTAINER_NAME ?= ${HOSTNAME}_container

image:
	docker build -t ${IMAGE_NAME} .

start:
	docker run --name ${CONTAINER_NAME} -d \
		-p 8080:8080 -p 50000:50000 \
		--restart=on-failure \
		--volume jenkins_home:/var/jenkins_home \
		-v /var/run/docker.sock:/var/run/docker.sock \
		${IMAGE_NAME} \
	|| \
	docker start ${CONTAINER_NAME}
	echo ${DOCKER_PATH}

stop:
	-docker stop ${CONTAINER_NAME}

join: start
	docker exec -it ${CONTAINER_NAME} /bin/bash

rm: stop
	-docker rm ${CONTAINER_NAME}

purge: rm
	-docker rmi ${IMAGE_NAME}

logs:
	docker logs ${CONTAINER_NAME}

.PHONY: image start join stop rm purge logs
