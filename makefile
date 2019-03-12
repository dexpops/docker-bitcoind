all: build run

run:
	docker stop bitcoind; \
	docker volume rm bitcoind-volume; \
	docker run --rm --name=bitcoind \
	-v /Users/kj/utxo/utxo-snapshot.tar:/utxo-snapshot.tar \
	-v bitcoind-volume:/app \
	-e BITCOIN_SNAPSHOT=/utxo-snapshot.tar \
	dexpops/docker-bitcoind:latest

stop:
	docker stop bitcoind

build:
	docker build -t dexpops/docker-bitcoind:latest .