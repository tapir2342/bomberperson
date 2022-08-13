IMAGE_TAG := latest
IMAGE_NAME := tapir2342/bomberperson-server
IMAGE := $(IMAGE_NAME):$(IMAGE_TAG)
CONTAINER := bomberperson-server
SERVER_IP := 51.15.71.106

all: server-publish

server-build:
	docker build -t $(IMAGE) -f server.Dockerfile .

# Cannot be killed with Ctrl+C. Use `docker ps` and `docker stop <container-id>`.
server-run: server-build
	docker run -it $(IMAGE)

server-publish: server-build
	docker push $(IMAGE)
	ssh root@$(SERVER_IP) 'docker pull $(IMAGE)'
	-ssh root@$(SERVER_IP) 'docker container kill $(CONTAINER)'
	-ssh root@$(SERVER_IP) 'docker container rm $(CONTAINER)'
	ssh root@$(SERVER_IP) 'docker run --name $(CONTAINER) -d -it -p 23420:23420/udp $(IMAGE)'
	-ssh root@$(SERVER_IP) 'docker container prune --force'

server-logs:
	ssh root@$(SERVER_IP) 'docker logs -f $(CONTAINER)'

