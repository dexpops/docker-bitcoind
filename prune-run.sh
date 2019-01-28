#!/bin/bash

docker stop bitcoind 
docker rm bitcoind
docker volume rm bitcoind-volume

docker run --name=bitcoind \
-v bitcoind-volume:/app \
-v utxo-data:/utxo:ro \
-d dexpops/docker-bitcoind:v0.17.1-build-7

docker logs -f bitcoind
