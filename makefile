all: build run

prune-run:

	docker stop bitcoind
	docker rm bitcoind
	docker volume rm bitcoind-volume

	docker run --rm --name=bitcoind \
	-v bitcoind-volume:/app \
	-d dexpops/docker-bitcoind:v0.17.1-build-5

run:
	docker stop bitcoind

	docker run --rm --name=bitcoind \
	-v bitcoind-volume:/app \
	-d dexpops/docker-bitcoind:v0.17.1-build-5

stop:
	docker stop bitcoind

prune:
	docker stop bitcoind
	docker rm bitcoind
	docker volume rm bitcoind-volume

build:
	docker build -t dexpops/docker-bitcoind:v0.17.1-build-5 .
