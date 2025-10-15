#!/bin/bash

echo "Copying enodes to configValidators.toml..."

# Path to folders
KEYS_DIR="./QBFT-Network/networkFiles/keys"
NODO_BASE="Node"
ENODE_CONFIG="config/configValidators.toml"
TMP_FILE=$(mktemp)
ENODE_WITH_IP=$(grep "^bootnodes" "$ENODE_CONFIG" | sed -E 's/bootnodes=\[(.*)\]/\1/')

echo "$ENODE_WITH_IP"  # Agregar $ para mostrar el valor de la variable

# Node counter (starting in 1 → Node-1)
i=1
# sort the directories in KEYS_DIR and iterate through them
for address_dir in $(ls "$KEYS_DIR" | sort); do
  permit_file="QBFT-Network/$NODO_BASE-$i/data/permissions_config.toml"
  if [[ -f "$permit_file" ]]; then  
    # Replace or insert nodes-allowlist line
    if grep -q "^nodes-allowlist" "$permit_file"; then
      sed "s|^nodes-allowlist=.*|nodes-allowlist=[$ENODE_WITH_IP]|" "$permit_file" > "$TMP_FILE"
    else
      echo "nodes-allowlist=$ENODE_WITH_IP" >> "$permit_file"
      cp "$permit_file" "$TMP_FILE"
    fi
    mv "$TMP_FILE" "$permit_file"
    echo "$NODO_BASE-$i 's permissions_config.toml updated with:"
    echo "  $ENODE_WITH_IP"
  else
    echo "File unmatched: $permit_file"  # Corregir variables que no existen
  fi

  i=$((i + 1))
done
