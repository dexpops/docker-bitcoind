#!/bin/bash

docker stop bitcoind 
docker rm bitcoind
docker volume rm bitcoind-volume

docker run --rm --name=bitcoind \
-v bitcoind-volume:/app \
-v /home/core/utxo-snapshot-bitcoin-mainnet-551636.tar:/utxo-sets/utxo-snapshot-bitcoin-mainnet-551636.tar \
-d dexpops/docker-bitcoind:0.17.1-build-4

docker logs -f bitcoind
