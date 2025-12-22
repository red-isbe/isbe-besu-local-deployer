#!/bin/bash

# -----------------------------------------------------------------------------------
# Copyright (c) 2025 Comunidad de Madrid & Alastria
# Licensed under the Apache License, Version 2.0 (the "License");
# You may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# -----------------------------------------------------------------------------------

# Usage: ./getEnode.sh <BOOTNODE_IP>
if [ $# -ne 1 ]; then
  echo "Usage: $0 <BOOTNODE_IP>"
  exit 1
fi

BOOTNODE_IP=$1

echo "Obtaining enode for bootnode IP: $BOOTNODE_IP..."

# Try multiple ways to obtain the enode, with retries. This handles differences
# between macOS and WSL/Docker Desktop where localhost vs container network
# reachability can differ.
try_get_enode() {
  # 1) Prefer querying the bootnode container directly via docker exec (most reliable)
  if docker ps -a --format '{{.Names}}' | grep -wq '^bootnode$'; then
    ENODE=$(docker exec bootnode sh -c "curl -s -X POST -H 'Content-Type: application/json' --data '{\"jsonrpc\":\"2.0\",\"method\":\"admin_nodeInfo\",\"params\":[],\"id\":1}' http://localhost:8545" 2>/dev/null | jq -r '.result.enode')
    if [ -n "$ENODE" ] && [[ "$ENODE" != "null" ]]; then
      echo "$ENODE"
      return 0
    fi
  fi

  # 2) Query localhost:8545 on the host (works when port is published and accessible)
  ENODE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://localhost:8545 2>/dev/null | jq -r '.result.enode')
  if [ -n "$ENODE" ] && [[ "$ENODE" != "null" ]]; then
    echo "$ENODE"
    return 0
  fi

  # 3) Try contacting the bootnode container IP (may not be reachable from host in some setups)
  ENODE=$(curl -s -X POST -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' http://$BOOTNODE_IP:8545 2>/dev/null | jq -r '.result.enode')
  if [ -n "$ENODE" ] && [[ "$ENODE" != "null" ]]; then
    echo "$ENODE"
    return 0
  fi

  return 1
}

ENODE=""
RETRIES=8
SLEEP_SECONDS=5
for i in $(seq 1 $RETRIES); do
  echo "Attempt $i/$RETRIES to get enode..."
  if ENODE=$(try_get_enode); then
    break
  fi
  sleep $SLEEP_SECONDS
done

if [ -z "$ENODE" ] || [[ "$ENODE" == "null" ]]; then
  echo "Error: Could not obtain enode from bootnode (tried docker exec, localhost and $BOOTNODE_IP)."
  echo "Check 'docker logs bootnode' and that RPC 8545 is listening and accessible."
  exit 1
fi

# Replace IP part of the enode with the provided BOOTNODE_IP so other nodes can use it
ENODE_WITH_IP=$(echo "$ENODE" | sed -E "s/@[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/@$BOOTNODE_IP/")

echo "ENODE with correct IP: $ENODE_WITH_IP"

CONFIG_FILE="./config/configValidators.toml"
TMP_FILE=$(mktemp)

echo "Updating $CONFIG_FILE with the new enode..."

# Replace or insert bootnodes line
if [ -f "$CONFIG_FILE" ] && grep -q "^bootnodes" "$CONFIG_FILE"; then
  sed "s|^bootnodes=.*|bootnodes=[\"$ENODE_WITH_IP\"]|" "$CONFIG_FILE" > "$TMP_FILE"
else
  echo "bootnodes=[\"$ENODE_WITH_IP\"]" > "$TMP_FILE"
  if [ -f "$CONFIG_FILE" ]; then
    cat "$CONFIG_FILE" >> "$TMP_FILE"
  fi
fi

mv "$TMP_FILE" "$CONFIG_FILE"
echo "configValidators.toml updated with:"
echo "  $ENODE_WITH_IP"
