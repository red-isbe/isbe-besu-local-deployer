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
  RPC_PORT=$((8545 + PORT_OFFSET))
  METRICS_PORT=$((9546 + PORT_OFFSET))
  NODE_IP="$BASE_IP.$((30 + PORT_OFFSET))"

  echo "Starting $NODE_NAME with IP $NODE_IP and ports: P2P=$P2P_PORT, RPC=$RPC_PORT, METRICS=$METRICS_PORT"

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
    hyperledger/besu:$BESU_VERSION \
    --config-file=/opt/besu/config/configValidators.toml \
    --p2p-port=$P2P_PORT \
    --rpc-http-port=$RPC_PORT \
    --metrics-port=$METRICS_PORT
done

# Generate explorer config deterministically from NUM_VALIDATORS
EXPLORER_CONFIG="explorer/src/config/config.json"

echo "Generating $EXPLORER_CONFIG for $NUM_VALIDATORS validators"

nodes_json=""

# Node-1 as bootnode
nodes_json="{\"name\": \"bootnode\", \"client\": \"besu\", \"rpcUrl\": \"http://127.0.0.1:8545\", \"privateTxUrl\": \"\"}"

# Remaining nodes as node1..nodeN-1
if [ "$NUM_VALIDATORS" -ge 2 ]; then
  for ((i = 1; i <= (NUM_VALIDATORS - 1); i++)); do
    idx=$((i + 1))
    rpc_port=$((8545 + i))
    entry="{\"name\": \"node$idx\", \"client\": \"besu\", \"rpcUrl\": \"http://127.0.0.1:$rpc_port\", \"privateTxUrl\": \"\"}"
    nodes_json="$nodes_json, $entry"
  done
fi

mkdir -p "$(dirname "$EXPLORER_CONFIG")"
cat > "$EXPLORER_CONFIG" <<EOF
{
  "algorithm": "qbft",
  "nodes": [
    $nodes_json
  ]
}
EOF

echo "Explorer config written to $EXPLORER_CONFIG"
