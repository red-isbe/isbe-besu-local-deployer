#!/bin/bash

BESU_VERSION=$1 # Besu version to use
NUM_VALIDATORS=$2  # Total number of validator nodes
BASE_IP=$3 # Base IP address for the network (e.g., 172.16.240)
NETWORK_NAME="besu-network" 


# Create Docker network if it does not exist
docker network inspect $NETWORK_NAME >/dev/null 2>&1 || \
docker network create --driver=bridge --subnet=$BASE_IP.0/24 $NETWORK_NAME

# Loop through validator nodes 
for ((i = 2; i <= NUM_VALIDATORS; i++)); do
  NODE_NAME="node$i"
  NODE_DIR="QBFT-Network/Node-$i/data"
  mkdir -p "$NODE_DIR"

  PORT_OFFSET=$((i - 1))
  P2P_PORT=$((30304 + PORT_OFFSET))
  RPC_PORT=$((8546 + PORT_OFFSET))
  METRICS_PORT=$((9546 + PORT_OFFSET))
  NODE_IP="$BASE_IP.$((30 + PORT_OFFSET))"

  echo "Starting $NODE_NAME with IP $NODE_IP and ports: P2P=$P2P_PORT, RPC=$RPC_PORT, METRICS=$METRICS_PORT"

  # Extract version from full image reference if provided
  CLEAN_VERSION="$BESU_VERSION"
  if [[ $BESU_VERSION == *":"* ]]; then
    CLEAN_VERSION=$(echo "$BESU_VERSION" | cut -d':' -f2)
  fi

  docker run -d --name $NODE_NAME \
    -v "$(pwd)/config:/opt/besu/config" \
    -v "$(pwd)/QBFT-Network/Node-$i/data:/opt/besu/data" \
    -v "$(pwd)/plugins:/opt/besu/plugins" \
    -p $P2P_PORT:$P2P_PORT \
    -p $RPC_PORT:$RPC_PORT \
    -p $METRICS_PORT:$METRICS_PORT \
    --label project=besu \
    --network $NETWORK_NAME \
    --ip $NODE_IP \
    hyperledger/besu:$CLEAN_VERSION \
    --config-file=/opt/besu/config/configValidators.toml \
    --p2p-port=$P2P_PORT \
    --rpc-http-port=$RPC_PORT \
    --metrics-port=$METRICS_PORT
done
