#!/bin/bash

echo "Stopping and removing Docker containers using 'hyperledger/besu' image... "

docker ps -a --filter "label=project=besu" -q | xargs -r docker stop
docker ps -a --filter "label=project=besu" -q | xargs -r docker rm

echo "Cleaning QBFT-Network directory content..."
if [ -d "QBFT-Network" ]; then
  find QBFT-Network -mindepth 1 ! -name ".gitkeep" -exec rm -rf {} +
fi
echo "Deleting config/genesis.json..."
rm -f config/genesis.json

if docker network inspect besu-network >/dev/null 2>&1; then
  echo "Removing old Docker network 'besu-network'..."
  docker network rm besu-network >/dev/null 2>&1 || true
fi

echo "Cleanup complete."
