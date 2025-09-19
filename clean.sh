#!/bin/bash

echo "Stopping and removing Docker containers with docker-compose..."

docker-compose down -v 2>/dev/null

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

if docker network inspect isbe-besu-local-deployer_besu-network >/dev/null 2>&1; then
  echo "Removing Docker Compose network 'isbe-besu-local-deployer_besu-network'..."
  docker network rm isbe-besu-local-deployer_besu-network >/dev/null 2>&1 || true
fi

echo "Cleanup complete."
