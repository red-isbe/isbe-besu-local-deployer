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
num_nodes=""
besuVersion=""
chainId=""
blockperiodseconds=""
ellipticCurve=""
ip=""

while getopts "n:v:c:b:e:i:y" opt; do
  case $opt in
    n) num_nodes=$OPTARG ;;
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
besuVersion=${besuVersion:-"24.12.2"}
chainId=${chainId:-2222}
blockperiodseconds=${blockperiodseconds:-2}
ellipticCurve=${ellipticCurve:-"secp256k1"}
ip=${ip:-"172.16.240"}

# Check if defaults were used
defaults_used=false
if [[ $OPTIND -eq 1 ]]; then
  defaults_used=true
fi

# If defaults used and not yes flag, display and confirm
if [[ "$defaults_used" == true && "$yes_flag" != true ]]; then
  echo "Using default configuration:"
  echo "  Number of nodes: $num_nodes"
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
if ! [[ "$besuVersion" =~ ^[0-9]{2}\.[0-9]{2}\.[0-9]+$ ]]; then
  echo "Invalid Besu version format. Use like 24.12.2"
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
docker-compose down -v 2>/dev/null

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

# Create the custom Docker network if not already created
docker network inspect besu-network >/dev/null 2>&1 || docker network create --driver=bridge --subnet=${ip}.0/24 besu-network

# Return to the parent directory
cd ..

# Start the bootnode container
docker run -d --name bootnode \
  -v "$(pwd)/config:/opt/besu/config" \
  -v "$(pwd)/QBFT-Network/Node-1/data:/opt/besu/data" \
  -v "$(pwd)/plugins:/opt/besu/plugins" \
  -p 30303:30303 \
  -p 8545:8545 \
  -p 9545:9545 \
  --label project-besu \
  --network besu-network \
  --ip ${ip}.30 \
  hyperledger/besu:$besuVersion \
  --config-file=/opt/besu/config/configBootnode.toml

# Wait for the bootnode to be ready
echo "Waiting for the bootnode to be ready..."
while ! curl -s -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' -H "Content-Type: application/json" http://localhost:8545 | jq -r '.result.enode' 2>/dev/null | grep -q '^enode://'; do
  echo "Bootnode not ready, waiting..."
  sleep 5
done

# Fetch the bootnode enode and insert it into the validator config
bash getEnode.sh ${ip}.30

# Launch all validator node containers
bash createValidatorNodes.sh $besuVersion $num_nodes $ip

# Finish
echo "Setup Complete. Besu network starting! 🚀"