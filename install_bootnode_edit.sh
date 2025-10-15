#!/bin/bash

# Check if Docker is installed and running
if ! command -v docker &>/dev/null; then
  echo "Docker could not be found. Please install Docker and try again."
  exit 1
fi
if ! docker info &>/dev/null; then
  echo "Docker is not running. Please start Docker and try again."
  exit 1
fi
echo "Docker is installed and running."

# Parse command line arguments
yes_flag=false
num_bootnodes=""
num_nodes=""
besuVersion=""
chainId=""
blockperiodseconds=""
ellipticCurve=""
ip=""

while getopts "n:t:v:c:b:e:i:y" opt; do
  case $opt in
    n) num_nodes=$OPTARG ;;
	t) num_bootnodes=$OPTARG ;;
    v) besuVersion=$OPTARG ;;
    c) chainId=$OPTARG ;;
    b) blockperiodseconds=$OPTARG ;;
    e) ellipticCurve=$OPTARG ;;
    i) ip=$OPTARG ;;
    y) yes_flag=true ;;
    *) echo "Usage: $0 [-n num_nodes] [-v besuVersion] [-c chainId] [-b blockperiodseconds] [-e ellipticCurve] [-i ip] [-y]"
       exit 1 ;;
  esac
done

# Set defaults
num_nodes=${num_nodes:-4}
num_bootnodes=${num_bootnodes:-2}
besuVersion=${besuVersion:-"24.12.2"}
chainId=${chainId:-2222}
blockperiodseconds=${blockperiodseconds:-2}
ellipticCurve=${ellipticCurve:-"secp256k1"}
ip=${ip:-"172.16.241"}

# Check if defaults were used
defaults_used=false
if [[ $OPTIND -eq 1 ]]; then
  defaults_used=true
fi

# If defaults used and not yes flag, display and confirm
if [[ "$defaults_used" == true && "$yes_flag" != true ]]; then
  echo "Using default configuration:"
  echo "  Number of nodes: $num_nodes"
  echo "  Of which are bootnodes: $num_bootnodes"
  echo "  Besu version: $besuVersion"
  echo "  Chain ID: $chainId"
  echo "  Block period: $blockperiodseconds seconds"
  echo "  Elliptic curve: $ellipticCurve"
  echo "  IP mask: $ip"
  read -p "Do you want to proceed with these settings? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    echo "Aborting."
    exit 1
  fi
fi

# Validate inputs
if ! [[ "$num_nodes" =~ ^[0-9]+$ ]] || (( num_nodes < 4 || num_nodes > 100 )); then
  echo "Number of nodes must be between 4 and 100."
  exit 1
fi
if ! [[ "$num_bootnodes" =~ ^[0-9]+$ ]] || (( num_bootnodes < 1 || num_bootnodes > num_nodes )); then
  echo "Number of bootnodes must be between 1 and number of total nodes."
  exit 1
fi
if ! [[ "$besuVersion" =~ ^[0-9]{2}\.[0-9]{1,2}\.[0-9]+$ ]]; then
  echo "Invalid Besu version format. Use like 24.12.2 or 25.8.0"
  exit 1
fi
if ! [[ "$chainId" =~ ^[0-9]+$ ]] || (( chainId < 1 )); then
  echo "Chain ID must be a positive integer."
  exit 1
fi
if ! [[ "$blockperiodseconds" =~ ^[0-9]+$ ]] || (( blockperiodseconds < 1 || blockperiodseconds > 30 )); then
  echo "Block period must be between 1 and 30 seconds."
  exit 1
fi
if [[ "$ellipticCurve" != "secp256k1" && "$ellipticCurve" != "secp256r1" ]]; then
  echo "Elliptic curve must be secp256k1 or secp256r1."
  exit 1
fi
if ! [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid IP mask format."
  exit 1
fi

# Check for running Besu containers
running_containers=$(docker ps --filter "label=project-besu" -q)
if [[ -n "$running_containers" ]]; then
  if [[ "$yes_flag" != true ]]; then
    echo "There are running Besu containers:"
    docker ps --filter "label=project-besu" --format "table {{.Names}}\t{{.Status}}"
    read -p "Do you want to stop and remove them? (y/n): " confirm
    if [[ "$confirm" != "y" ]]; then
      echo "Aborting."
      exit 1
    fi
  fi
  docker stop $running_containers
  docker rm $running_containers
fi

# Clean up previous setup and containers
echo "Cleaning up previous setup folders..."
docker compose down -v 2>/dev/null

# Clean QBFT-Network directory
if [ -d "QBFT-Network" ]; then
  find QBFT-Network -mindepth 1 ! -name ".gitkeep" -exec rm -rf {} +
fi
rm -f config/genesis.json

# Wait for containers to be fully removed
while docker ps -a --filter "label=project-besu" -q | grep -q .; do
  echo "Waiting for containers to be removed..."
  sleep 2
done

# Update genesis file with provided parameters
jq --argjson chainId "$chainId" '.genesis.config.chainId = $chainId' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson blockperiodseconds "$blockperiodseconds" '.genesis.config.qbft.blockperiodseconds = $blockperiodseconds' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson count "$num_nodes" '.blockchain.nodes.count = $count' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json
jq --arg ec "$ellipticCurve" '.genesis.config.ecCurve = $ec' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

# Create directory structure for validator nodes
mkdir -p QBFT-Network
i=1
while [ "$i" -le "$num_nodes" ]; do
  mkdir -p "QBFT-Network/Node-$i/data"
  i=`expr $i + 1`
done

cd QBFT-Network

# Generate genesis and validator keys using Besu
docker run --rm \
  -v "$(pwd)/../config:/opt/besu/config" \
  -v "$(pwd):/opt/besu/output" \
  hyperledger/besu:$besuVersion \
  operator generate-blockchain-config \
  --config-file=/opt/besu/config/qbftConfigFile.json \
  --to=/opt/besu/output/networkFiles \
  --private-key-file-name=key 2>/dev/null


# Copy the generated genesis to the config folder
cp networkFiles/genesis.json ../config/genesis.json

# Move the generated validator keys to each node's data folder
bash ../moveKeys.sh 

# Create the permissions_config.toml file in each node's data folder
bash ../createPermitList.sh 

# Return to the parent directory
cd ..

# Generate docker-compose.yml
echo "Node 1 (bootnode 1)..."
cat > docker-compose.yml << EOF
networks:
  besu-network:
    driver: bridge
    ipam:
      config:
        - subnet: ${ip}.0/24

volumes:
  config:
  plugins:

services:
  bootnode:
    image: hyperledger/besu:${besuVersion}
    container_name: bootnode
    volumes:
      - ./config:/opt/besu/config
      - ./QBFT-Network/Node-1/data:/opt/besu/data
      - ./plugins:/opt/besu/plugins
    ports:
      - "30303:30303"
      - "8545:8545"
      - "9545:9545"
    networks:
      besu-network:
        ipv4_address: ${ip}.30
    command: --config-file=/opt/besu/config/configBootnode.toml
    labels:
      - "project-besu"
    deploy:
      replicas: 1
EOF

for ((i=2; i<=num_bootnodes; i++)); do
  port_offset=$((i-1))
  echo "Node $i (bootnode $i)..."
  p2p_port=$((30303 + port_offset))
  rpc_port=$((8545 + port_offset))
  metrics_port=$((9545 + port_offset))
  node_ip="${ip}.$((30 + port_offset))"
  cat >> docker-compose.yml << EOF
  bootnode$i:
    image: hyperledger/besu:${besuVersion}
    container_name: bootnode$i
    volumes:
      - ./config:/opt/besu/config
      - ./QBFT-Network/Node-$i/data:/opt/besu/data
      - ./plugins:/opt/besu/plugins
    ports:
      - "${p2p_port}:${p2p_port}"
      - "${rpc_port}:${rpc_port}"
      - "${metrics_port}:${metrics_port}"
    networks:
      besu-network:
        ipv4_address: ${node_ip}
    command: --config-file=/opt/besu/config/configBootnode.toml --p2p-port=${p2p_port} --rpc-http-port=${rpc_port} --metrics-port=${metrics_port}
    depends_on:
      - bootnode
    labels:
      - "project-besu"
    deploy:
      replicas: 1
EOF
done

for ((i=num_bootnodes+1; i<=num_nodes; i++)); do
  port_offset=$((i-1))
  echo "Node $i (Validation node $((i-num_bootnodes)))..."
  p2p_port=$((30304 + port_offset))
  rpc_port=$((8546 + port_offset))
  metrics_port=$((9546 + port_offset))
  node_ip="${ip}.$((30 + port_offset))"
  cat >> docker-compose.yml << EOF
  node$i:
    image: hyperledger/besu:${besuVersion}
    container_name: node$i
    volumes:
      - ./config:/opt/besu/config
      - ./QBFT-Network/Node-*#%J0R8ecoFoNJyLF%#*$i/data:/opt/besu/data
      - ./plugins:/opt/besu/plugins
    ports:
      - "${p2p_port}:${p2p_port}"
      - "${rpc_port}:${rpc_port}"
      - "${metrics_port}:${metrics_port}"
    networks:
      besu-network:
        ipv4_address: ${node_ip}
    command: --config-file=/opt/besu/config/configValidators.toml --p2p-port=${p2p_port} --rpc-http-port=${rpc_port} --metrics-port=${metrics_port}
    depends_on:
      - bootnode
    labels:
      - "project-besu"
    deploy:
      replicas: 1
EOF
done

# Start the bootnode with docker-compose
docker compose up -d bootnode

# Wait for the bootnode to be ready
echo "Waiting for the bootnode to be ready..."
while ! curl -s -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545 | jq -r '.result.enode' 2>/dev/null | grep -q '^enode://'; do
  echo "Bootnode not ready, waiting..."
  sleep 5
done

# Fetch the bootnode enode and insert it into the validator config
bash getEnode.sh ${ip}.30
for ((i=2; i<=num_bootnodes; i++)); do
  bash getEnode_bootnode_edit.sh "${ip}.$((30 + $((i-1))))"
done

# Launch all validator node containers with docker-compose
docker compose up -d --wait

# Finish
echo "Setup Complete. Besu network starting! 🚀"