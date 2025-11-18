#!/bin/bash

#=============================================================================
# Hyperledger Besu QBFT Network Deployer
#=============================================================================
# This script automatically deploys a Hyperledger Besu QBFT network using Docker
#
# SUPPORTED ELLIPTIC CURVES:
#   - secp256k1 (default) - Standard Ethereum-compatible curve
#   - secp256r1           - FIPS/NIST compliant curve for regulatory environments
#
# DEFAULT CONFIGURATION:
#   - 4 validator nodes
#   - Besu version: 25.9.0
#   - Elliptic Curve: secp256k1
#   - Chain ID: 2222
#   - Block period: 2 seconds
#   - Network IP: 172.16.240.0/24
#=============================================================================

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

# Default configuration parameters (load current config and keep as defaults)
default=""
advanced=""
chainId=$(jq -r '.genesis.config.chainId // empty' ./config/qbftConfigFile.json)
chainId=${chainId:-$default_chainId}
blockperiodseconds=$(jq -r '.genesis.config.qbft.blockperiodseconds // empty' ./config/qbftConfigFile.json)
blockperiodseconds=${blockperiodseconds:-$default_blockperiodseconds}
epochlength=$(jq -r '.genesis.config.qbft.epochlength // empty' ./config/qbftConfigFile.json)
epochlength=${epochlength:-$default_epochlength}
num_nodes=$(jq -r '.blockchain.nodes.count // empty' ./config/qbftConfigFile.json)
num_nodes=${num_nodes:-$default_num_nodes}
ecCurve=$(jq -r '.genesis.config.ecCurve // empty' ./config/qbftConfigFile.json)
ecCurve=${ecCurve:-$default_ecCurve}
besuVersion=$(jq -r '.blockchain.nodes.besuVersion // empty' ./config/qbftConfigFile.json)
besuVersion=${besuVersion:-$default_besuVersion}
ip=$(jq -r '.blockchain.nodes.ip // empty' ./config/qbftConfigFile.json)
ip=${ip:-$default_ip}

# Preserve defaults for prompts
def_chainId="$chainId"
def_blockperiodseconds="$blockperiodseconds"
def_epochlength="$epochlength"
def_num_nodes="$num_nodes"
def_ecCurve="$ecCurve"
def_besuVersion="$besuVersion"
def_ip="$ip"


# --- New: parse -y / --yes to skip prompts and apply defaults ---
auto_yes=false
for arg in "$@"; do
  if [[ "$arg" == "-b" || "$arg" == "--batch" ]]; then
    auto_yes=true
    default="y"
    break
  fi
done

# Ask user if they want to change the default configuration
if [ "$auto_yes" = true ]; then
  echo "Auto-confirmation enabled (-y): applying default configuration..."
else
  while [[ $default != "y" && $default != "n" ]]; do
    read -p "Do you want to -- APPLY THIS CONFIGURATION ? [default enter key value] --  (validators nodes: $num_nodes, Besu version: $besuVersion, Elliptic Curve: $ecCurve, chainId: $chainId, sec between blocks: $blockperiodseconds, epoch length: $epochlength, IP: $ip) [Y/n]: " default
    if [[ -z $default ]]; then default="y"; fi
    if [[ $default != "y" && $default != "n" ]]; then
      echo "Please enter 'y' or 'n'."
    fi
  done
fi

# Update genesis file with default chainId and block period
jq --argjson chainId "$chainId" '.genesis.config.chainId = $chainId' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson blockperiodseconds "$blockperiodseconds" '.genesis.config.qbft.blockperiodseconds = $blockperiodseconds' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson epochlength "$epochlength" '.genesis.config.qbft.epochlength = $epochlength' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson count "$num_nodes" '.blockchain.nodes.count = $count' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json
jq --arg ec "$ecCurve" '.genesis.config.ecCurve = $ec' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json


# If custom configuration is selected
if [[ $default == "n" ]]; then
  # Keep current values as defaults; allow Enter to accept them

  # Prompt user for number of nodes
  while true; do
    read -p "Enter the number of nodes (including the bootnode, minimum 4) [$num_nodes]: " ans
    if [[ -z "$ans" ]]; then
      break
    fi
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 4 && ans <= 100 )); then
      num_nodes=$ans
      break
    else
      echo "You must create at least 4 nodes and maximum 100. Please try again."
    fi
  done
  jq --argjson count "$num_nodes" '.blockchain.nodes.count = $count' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for Besu version
  while true; do
    read -p "Enter the version of Besu (format: 25.9.0 or latest) [$besuVersion]: " ans
    if [[ -z "$ans" ]]; then
      break
    fi
    if [[ $ans =~ ^[0-9]+\.[0-9]+\.[0-9]+$ || $ans == "latest" ]]; then
      besuVersion="$ans"
      break
    else
      echo "Invalid version format. Please use format like 25.9.0 or write \"latest\""
    fi
  done
  jq --arg besuVersion "$besuVersion" '.blockchain.nodes.besuVersion = $besuVersion' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for chain ID
  while true; do
    read -p "Enter the chain ID (e.g. 1234) [$chainId]: " ans
    if [[ -z "$ans" ]]; then
      break
    fi
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 )); then
      chainId=$ans
      break
    else
      echo "You must enter a valid chain ID. Please try again."
    fi
  done
  jq --argjson chainId "$chainId" '.genesis.config.chainId = $chainId' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for block period
  while true; do
    read -p "Enter the block period in seconds (between 2 - 30) [$blockperiodseconds]: " ans
    if [[ -z "$ans" ]]; then
      break
    fi
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 2 && ans <= 30 )); then
      blockperiodseconds=$ans
      break
    else
      echo "You must enter a block period in seconds within the interval. Please try again."
    fi
  done
  jq --argjson blockperiodseconds "$blockperiodseconds" '.genesis.config.qbft.blockperiodseconds = $blockperiodseconds' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json

  # Prompt user for epoch length
  while true; do
    read -p "Enter the epoch length in blocks [$epochlength]: " ans
    if [[ -z "$ans" ]]; then
      break
    fi
    if [[ "$ans" =~ ^[0-9]+$ ]] && (( ans >= 1 )); then
      epochlength=$ans
      break
    else
      echo "You must enter a valid epoch length (>= 1). Please try again."
    fi
  done
  jq --argjson epochlength "$epochlength" '.genesis.config.qbft.epochlength = $epochlength' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json

  # Ask user if they want to change the network IP configuration
  while [[ $advanced != "y" && $advanced != "n" ]]; do
    read -p "Do you want to -- APPLY THIS CONFIGURATION ? (Elliptic Curve: secp256k1, IP Address: 172.16.240) [Y/n]: " advanced
    if [[ -z $advanced ]]; then advanced="y"; fi
    if [[ $advanced != "y" && $advanced != "n" ]]; then
      echo "Please enter 'y' or 'n'."
    fi
  done

  # If advanced network IP configuration is enabled
  if [[ $advanced == "n" ]]; then
    default_ip="172.16.240"
    default_curve="secp256k1"
    ip="$default_ip"
    ecCurve="$default_curve"
    # Elliptic curve selection
    while true; do
      read -p "Enter the elliptic curve (secp256k1 or secp256r1) [$default_curve]: " ans
      if [[ -z $ans ]]; then
        ecCurve="$default_curve"
        break
      fi
      if [[ $ans == "secp256k1" || $ans == "secp256r1" ]]; then
        ecCurve="$ans"
        break
      else
        echo "You must enter either 'secp256k1' or 'secp256r1'. Please try again."
      fi
    done
    jq --arg ec "$ecCurve" '.genesis.config.ecCurve = $ec' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

    # IP address mask input  
    while true; do
      read -p "Enter the IP address mask (first 3 numbers, e.g. 172.16.240) [$default_ip]: " ans
      if [[ -z $ans ]]; then
        ip="$default_ip"
        break
      fi

      # Validate format
      if [[ ! $ans =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "You must enter a valid IP address mask. Please try again."
        continue
      fi

      # Validate private range
      if [[ ! $ans =~ ^10\.[0-9]+\.[0-9]+$ && ! $ans =~ ^172\.(1[6-9]|2[0-9]|3[0-1])\.[0-9]+$ && ! $ans =~ ^192\.168\.[0-9]+$ ]]; then
        echo "The IP must be in a private range (10.x.x, 172.16-31.x, 192.168.x). Please try again."
        continue
      fi
      ip="$ans"
      break
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
