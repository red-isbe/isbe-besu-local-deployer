#!/bin/bash

# Usage: ./update-enode.sh <IP>
if [ $# -ne 1 ]; then
  echo "Usage: $0 <BOOTNODE_IP>"
  exit 1
fi

BOOTNODE_IP=$1

echo "Obtaining enode from $BOOTNODE_IP..."

# Query the enode using admin_nodeInfo from the bootnode
ENODE=$(curl -s -X POST --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' -H "Content-Type: application/json" localhost:8545 | jq -r '.result.enode')

if [ -z "$ENODE" ] || [[ "$ENODE" == "null" ]]; then
  echo "Error: Could not obtain enode from $BOOTNODE_IP"
  exit 1
fi

# Replace IP part of the enode
ENODE_WITH_IP=$(echo "$ENODE" | sed -E "s/@[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/@$BOOTNODE_IP/")

echo "ENODE with correct IP: $ENODE_WITH_IP"

CONFIG_FILE="./config/configValidators.toml"
TMP_FILE=$(mktemp)

echo "Updating $CONFIG_FILE with the new enode..."

# Replace or insert bootnodes line - adding to existing list instead of overwriting
if grep -q "^bootnodes" "$CONFIG_FILE"; then
  # Check if the new bootnode already exists to avoid duplicates
  if grep -q "\"$ENODE_WITH_IP\"" "$CONFIG_FILE"; then
    echo "Bootnode $ENODE_WITH_IP already exists, skipping..."
    cp "$CONFIG_FILE" "$TMP_FILE"
  else
    # Extract current bootnodes and add new one
    sed "s|^bootnodes=\[\(.*\)\]|bootnodes=[\1,\"$ENODE_WITH_IP\"]|" "$CONFIG_FILE" | \
    sed "s|bootnodes=\[,|bootnodes=[|" > "$TMP_FILE"
  fi
else
  echo "bootnodes=[\"$ENODE_WITH_IP\"]" >> "$CONFIG_FILE"
  cp "$CONFIG_FILE" "$TMP_FILE"
fi

mv "$TMP_FILE" "$CONFIG_FILE"
echo "configValidators.toml updated with:"
echo "  $ENODE_WITH_IP"
