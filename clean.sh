#!/bin/bash

echo "Stopping and removing Docker containers with label 'project-besu'..."

containers=$(docker ps -a --filter "label=project-besu" -q)
if [[ -n "$containers" ]]; then
  docker stop $containers
  docker rm $containers
fi

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
