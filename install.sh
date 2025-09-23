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

# Clean up previous setup and containers
echo "Cleaning up previous setup folders..."
docker-compose down -v 2>/dev/null

# Default configuration parameters
default=""
advanced=""
chainId=$(jq -r '.genesis.config.chainId // empty' ./config/qbftConfigFile.json)
chainId=${chainId:-$default_chainId}
blockperiodseconds=$(jq -r '.genesis.config.qbft.blockperiodseconds // empty' ./config/qbftConfigFile.json)
blockperiodseconds=${blockperiodseconds:-$default_blockperiodseconds}
num_nodes=$(jq -r '.blockchain.nodes.count // empty' ./config/qbftConfigFile.json)
num_nodes=${num_nodes:-$default_num_nodes}
ellipticCurve=$(jq -r '.genesis.config.ecCurve // empty' ./config/qbftConfigFile.json)
ellipticCurve=${ellipticCurve:-$default_ellipticCurve}
besuVersion=$(jq -r '.blockchain.nodes.besuVersion // empty' ./config/qbftConfigFile.json)
besuVersion=${besuVersion:-$default_besuVersion}
ip=$(jq -r '.blockchain.nodes.ip // empty' ./config/qbftConfigFile.json)
ip=${ip:-$default_ip}


# Ask user if they want to change the default configuration
while [[ $default != "y" && $default != "n" ]]; do
  read -p "Do you want to -- APPLY THIS CONFIGURATION ? --  (validators nodes: $num_nodes, Besu version: $besuVersion, Elliptic Curve: $ellipticCurve, chainId: $chainId, sec between blocks: $blockperiodseconds, IP: $ip) Please enter 'y' or 'n': " default
  if [[ $default != "y" && $default != "n" ]]; then
    echo "Please enter 'y' or 'n'."
  fi
done

# Update genesis file with default chainId and block period
jq --argjson chainId "$chainId" '.genesis.config.chainId = $chainId' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson blockperiodseconds "$blockperiodseconds" '.genesis.config.qbft.blockperiodseconds = $blockperiodseconds' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson count "$num_nodes" '.blockchain.nodes.count = $count' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json
jq --arg ec "$ellipticCurve" '.genesis.config.ecCurve = $ec' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json


# If custom configuration is selected
if [[ $default == "n" ]]; then
  chainId=0
  blockperiodseconds=0
  num_nodes=0
  besuVersion=""

  # Prompt user for number of nodes
  while [[ $num_nodes -lt 4 || $num_nodes -gt 100 ]]; do
    read -p "Enter the number of nodes (including the bootnode, minimum 4): " num_nodes
    if [[ "$num_nodes" =~ ^[0-9]+$ ]] && (( num_nodes >= 4 && num_nodes <= 100 )); then
      break
    else
      echo "You must create at least 4 nodes and maximum 100. Please try again."
    fi
  done
  jq --argjson count "$num_nodes" '.blockchain.nodes.count = $count' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for Besu version
  while [[ ! $besuVersion =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && $besuVersion != "latest" ]]; do
    read -p "Enter the version of Besu (format: 24.12.2 or latest): " besuVersion
    if [[ ! $besuVersion =~ ^[0-9]+\.[0-9]+\.[0-9]+$ && $besuVersion != "latest" ]]; then
      echo "Invalid version format. Please use format like 24.12.2 or write \"latest\""
    fi
  done
  jq --arg besuVersion "$besuVersion" '.blockchain.nodes.besuVersion = $besuVersion' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for chain ID
  while [[ $chainId -lt 1 ]]; do
    read -p "Enter the chain ID (e.g. 1234): " chainId
    if [[ $chainId -lt 1 ]]; then
      echo "You must enter a valid chain ID. Please try again."
    fi
  done
  jq --argjson chainId "$chainId" '.genesis.config.chainId = $chainId' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for block period
  while [[ $blockperiodseconds -lt 1 || $blockperiodseconds -gt 30 ]]; do
    read -p "Enter the block period in seconds (between 2 - 30): " blockperiodseconds
    if [[ $blockperiodseconds -lt 2 || $blockperiodseconds -gt 30 ]]; then
      echo "You must enter a block period in seconds within the interval. Please try again."
    fi
  done
  jq --argjson blockperiodseconds "$blockperiodseconds" '.genesis.config.qbft.blockperiodseconds = $blockperiodseconds' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json

  # Ask user if they want to change the network IP configuration
  while [[ $advanced != "y" && $advanced != "n" ]]; do
    read -p "Do you want to -- CHANGE THE ADVANCE CONFIGURATION -- ?  (Elliptic Curve, IP Address) Please enter 'y' or 'n': " advanced
    if [[ $advanced != "y" && $advanced != "n" ]]; then
      echo "Please enter 'y' or 'n'."
    fi
  done

  # If advanced network IP configuration is enabled
  if [[ $advanced == "y" ]]; then
    ip=""
    ellipticCurve=""
    # Eliptic curve selection
    while [[ $ellipticCurve != "secp256k1" && $ellipticCurve != "secp256r1" ]]; do
      read -p "Enter the elliptic curve (secp256k1 or secp256r1): " ellipticCurve
      if [[ $ellipticCurve != "secp256k1" && $ellipticCurve != "secp256r1" ]]; then
        echo "You must enter either 'secp256k1' or 'secp256r1'. Please try again."
      fi
    done
    jq --arg ec "$ellipticCurve" '.genesis.config.ecCurve = $ec' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

    # IP address mask input  
    while [[ $ip == "" ]]; do
      read -p "Enter the IP address mask (first 3 numbers, e.g. 172.16.240): " ip
      
      # Validate format
      if [[ ! $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "You must enter a valid IP address mask. Please try again."
        ip=""
        continue
      fi

      # Validate private range
      if [[ ! $ip =~ ^10\.[0-9]+\.[0-9]+$ && ! $ip =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\.[0-9]+$ && ! $ip =~ ^192\.168\.[0-9]+$ ]]; then
        echo "The IP must be in a private range (10.x.x, 172.16-31.x, 192.168.x). Please try again."
        ip=""
        continue
      fi
    done
    jq --arg ip "$ip" '.blockchain.nodes.ip = $ip' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json
  fi
  echo "Deploying Besu! " 
fi

echo "Cleaning previous Docker Besu containers and folders from previous installations..."

docker ps -a --filter "label=project=besu" -q | xargs -r docker stop
docker ps -a --filter "label=project=besu" -q | xargs -r docker rm

if [ -d "QBFT-Network" ]; then
  find QBFT-Network -mindepth 1 ! -name ".gitkeep" -exec rm -rf {} +
fi
rm -f config/genesis.json

if docker network inspect besu-network >/dev/null 2>&1; then
  echo "Removing old Docker network 'besu-network'..."
  docker network rm besu-network >/dev/null 2>&1 || true
fi


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
  --label project=besu \
  --network besu-network \
  --ip ${ip}.30 \
  hyperledger/besu:$besuVersion \
  --config-file=/opt/besu/config/configBootnode.toml

# Wait for the bootnode to be ready
echo "Waiting for the bootnode to start some seconds ..."
sleep 10

# Fetch the bootnode enode and insert it into the validator config
bash getEnode.sh ${ip}.30

# Launch all validator node containers
bash createValidatorNodes.sh $besuVersion $num_nodes $ip

# Finish
echo "Setup Complete. Besu network starting! "