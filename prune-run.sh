#!/bin/bash

docker stop bitcoind
docker rm bitcoind
docker volume rm bitcoind-volume

docker run --name=bitcoind \
-v bitcoind-volume:/app \
-v ~/utxo:/utxo:ro \
-d dexpops/docker-bitcoind:latest

docker logs -f bitcoind
