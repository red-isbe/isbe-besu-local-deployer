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

# Default configuration parameters
default=""
advanced=""
chainId=2222
blockperiodseconds=2
num_nodes=4
besuVersion="25.9.0"
ellipticCurve="secp256k1"  # Default elliptic curve

# Supported elliptic curves
SUPPORTED_CURVES=("secp256k1" "secp256r1")
DEFAULT_CURVE="secp256k1"
ip="172.16.240"

# Read current elliptic curve from config
current_elliptic_curve=$(jq -r '.genesis.config.ellipticCurve // "secp256k1"' ./config/qbftConfigFile.json)

# Ask user if they want to change the default configuration
echo "Current configuration in qbftConfigFile.json:"
echo "  - Elliptic Curve: $current_elliptic_curve"
echo "  - Chain ID: $(jq -r '.genesis.config.chainId' ./config/qbftConfigFile.json)"
echo "  - Block Period: $(jq -r '.genesis.config.qbft.blockperiodseconds' ./config/qbftConfigFile.json) seconds"
echo "  - Node Count: $(jq -r '.blockchain.nodes.count' ./config/qbftConfigFile.json)"
echo ""
while [[ $default != "y" && $default != "n" ]]; do
  read -p "Do you want to -- CHANGE THE DEFAULT CONFIGURATION ? --  (4 validators nodes, Besu version 25.9.0, Elliptic Curve $current_elliptic_curve, chainId 2222, 2 sec between blocks, IP 172.16.240.0) Please enter 'y' or 'n': " default
  if [[ $default != "y" && $default != "n" ]]; then
    echo "Please enter 'y' or 'n'."
  fi
done

# Update genesis file with default chainId and block period
jq --argjson chainId "$chainId" '.genesis.config.chainId = $chainId' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson blockperiodseconds "$blockperiodseconds" '.genesis.config.qbft.blockperiodseconds = $blockperiodseconds' ./config/qbftConfigFile.json >temp.json && mv temp.json ./config/qbftConfigFile.json
jq --argjson count "$num_nodes" '.blockchain.nodes.count = $count' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json

# Set elliptic curve - use current value from config or use default
if [[ $default != "y" ]]; then
  # Use current config value if not changing configuration
  ellipticCurve=$current_elliptic_curve
fi

# Update both elliptic curve fields consistently
update_elliptic_curve() {
  local curve=$1
  jq --arg ec "$curve" '.genesis.config.ecCurve = $ec | .genesis.config.ellipticCurve = $ec' ./config/qbftConfigFile.json > temp.json && mv temp.json ./config/qbftConfigFile.json
}

# Function to display supported elliptic curves
display_supported_curves() {
  echo "Supported elliptic curves:"
  for i in "${!SUPPORTED_CURVES[@]}"; do
    local curve="${SUPPORTED_CURVES[$i]}"
    if [[ "$curve" == "$DEFAULT_CURVE" ]]; then
      echo "  - $curve (default)"
    else
      echo "  - $curve"
    fi
  done
}

# Function to verify elliptic curve configuration
verify_elliptic_curve_config() {
  local ec_curve=$(jq -r '.genesis.config.ecCurve // "not_set"' ./config/qbftConfigFile.json)
  local elliptic_curve=$(jq -r '.genesis.config.ellipticCurve // "not_set"' ./config/qbftConfigFile.json)
  
  if [[ "$ec_curve" == "$elliptic_curve" ]]; then
    echo "✅ Elliptic curve configuration is consistent: $ec_curve"
  else
    echo "⚠️  Elliptic curve configuration mismatch: ecCurve='$ec_curve', ellipticCurve='$elliptic_curve'"
    echo "Synchronizing both fields to: $elliptic_curve"
    update_elliptic_curve "$elliptic_curve"
  fi
}

# Function to validate elliptic curve input
is_valid_curve() {
  local curve=$1
  for supported_curve in "${SUPPORTED_CURVES[@]}"; do
    if [[ "$curve" == "$supported_curve" ]]; then
      return 0
    fi
  done
  return 1
}

update_elliptic_curve "$ellipticCurve"
verify_elliptic_curve_config
echo "Using elliptic curve: $ellipticCurve"


# If custom configuration is selected
if [[ $default == "y" ]]; then
  chainId=0
  blockperiodseconds=0
  num_nodes=0
  besuVersion=""
  ellipticCurve=""

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
  while [[ -z $besuVersion ]]; do
    read -p "Enter the version of Besu (format: 25.9.0): " besuVersion
    if [[ -z $besuVersion ]]; then
      echo "Please enter a Besu version (e.g., 25.9.0)"
    else
      # Extract version from full image reference if provided
      if [[ $besuVersion == *":"* ]]; then
        besuVersion=$(echo "$besuVersion" | cut -d':' -f2)
        echo "Extracted version: $besuVersion"
      fi
    fi
  done

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

  # Prompt user for elliptic curve
  echo "Current elliptic curve: $current_elliptic_curve"
  echo ""
  display_supported_curves
  echo ""
  while ! is_valid_curve "$ellipticCurve"; do
    read -p "Enter the elliptic curve (${SUPPORTED_CURVES[*]}): " ellipticCurve
    if ! is_valid_curve "$ellipticCurve"; then
      echo "Invalid elliptic curve '$ellipticCurve'. Please choose from: ${SUPPORTED_CURVES[*]}"
    fi
  done
  # Update elliptic curve configuration
  update_elliptic_curve "$ellipticCurve"
  verify_elliptic_curve_config
  echo "Updated elliptic curve to: $ellipticCurve"

  # Ask user if they want to change the network IP configuration
  while [[ $advanced != "y" && $advanced != "n" ]]; do
    read -p "Do you want to -- CHANGE THE IP ADDRESS CONFIGURATION -- ? Please enter 'y' or 'n': " advanced
    if [[ $advanced != "y" && $advanced != "n" ]]; then
      echo "Please enter 'y' or 'n'."
    fi
  done

  # If advanced network IP configuration is enabled
  if [[ $advanced == "y" ]]; then
    ip=""

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
  fi
fi

# Create directory structure for validator nodes
mkdir -p QBFT-Network
i=1
while [ "$i" -le "$num_nodes" ]; do
  mkdir -p "QBFT-Network/Node-$i/data"
  i=`expr $i + 1`
done

cd QBFT-Network

# Extract clean version for Docker commands
CLEAN_VERSION="$besuVersion"
if [[ $besuVersion == *":"* ]]; then
  CLEAN_VERSION=$(echo "$besuVersion" | cut -d':' -f2)
fi

# Generate genesis and validator keys using Besu
docker run --rm \
  -v "$(pwd)/../config:/opt/besu/config" \
  -v "$(pwd):/opt/besu/output" \
  hyperledger/besu:$CLEAN_VERSION \
  operator generate-blockchain-config \
  --config-file=/opt/besu/config/qbftConfigFile.json \
  --to=/opt/besu/output/networkFiles \
  --private-key-file-name=key 2>/dev/null


# Copy the generated genesis to the config folder
cp networkFiles/genesis.json ../config/genesis.json

# Validate that the elliptic curve was applied correctly
generated_ec=$(jq -r '.config.ecCurve // "not_set"' ../config/genesis.json)
if [[ "$generated_ec" != "$ellipticCurve" ]]; then
  echo "⚠️  Warning: Generated genesis file has elliptic curve '$generated_ec' but expected '$ellipticCurve'"
  echo "This may indicate an issue with the blockchain config generation."
else
  echo "✅ Verified: Genesis file correctly configured with elliptic curve '$ellipticCurve'"
fi

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
  hyperledger/besu:$CLEAN_VERSION \
  --config-file=/opt/besu/config/configBootnode.toml

# Wait for the bootnode to be ready
echo "Waiting for the bootnode to start some seconds ..."
sleep 10

# Fetch the bootnode enode and insert it into the validator config
bash getEnode.sh ${ip}.30

# Launch all validator node containers
bash createValidatorNodes.sh $CLEAN_VERSION $num_nodes $ip

# Finish
echo "Setup Complete. Besu network starting! 🚀"