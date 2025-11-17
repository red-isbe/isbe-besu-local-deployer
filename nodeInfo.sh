#!/bin/bash
# Script: listar_validadores.sh
# Recorre los contenedores de Besu y obtiene Enode + Dirección del validador

# Lista de contenedores a inspeccionar (ajusta a los tuyos)
CONTAINERS=$(docker ps --filter "label=project=besu" --format "{{.Names}}")

shorten() {
  s="$1"
  if [ -z "$s" ]; then echo "N/A"; return; fi
  # eliminar posibles saltos de línea
  s="$(printf '%s' "$s" | tr -d '\r\n')"
  len=${#s}
  if [ $len -le 12 ]; then echo "$s"; else echo "${s:0:6}...${s: -6}"; fi
}

shorten_enode() {
  e="$1"
  if [ -z "$e" ]; then echo "N/A"; return; fi
  # Esperado: enode://<pubkey>@host:port
  proto_removed="${e#enode://}"
  pub_and_host="${proto_removed}" # <pubkey>@host:port
  pubkey="${pub_and_host%@*}"
  hostport="${pub_and_host#*@}"
  spub=$(shorten "$pubkey")
  if [ -z "$hostport" ] || [ "$hostport" = "$pubkey" ]; then
    echo "enode://$spub"
  else
    echo "enode://$spub@$hostport"
  fi
}

echo "==========================================================================================="
echo " Nodo            | Enode (p2p)                           | PubKey          | Address"
echo "==========================================================================================="

for c in $CONTAINERS; do
  # Calcular puerto RPC en host de forma determinista (8545 bootnode, 8546 node2, ...)
  HOST_RPC_PORT=""
  if [ "$c" = "bootnode" ]; then
    HOST_RPC_PORT=8545
  elif [[ "$c" =~ ^node([0-9]+)$ ]]; then
    n=${BASH_REMATCH[1]}
    if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 2 ]; then
      HOST_RPC_PORT=$((8545 + n - 1))
    fi
  fi

  # Obtener el enode vía RPC (necesita admin_nodeInfo habilitado)
  ENODE=""
  if [ -n "$HOST_RPC_PORT" ]; then
    ENODE=$(curl -s -X POST "http://127.0.0.1:${HOST_RPC_PORT}" \
      -H "Content-Type: application/json" \
      --data '{"jsonrpc":"2.0","method":"admin_nodeInfo","params":[],"id":1}' \
      | jq -r '.result.enode' 2>/dev/null)
  fi

  # Obtener la dirección del validador desde la node key (sin TTY)
  ADDRESS=$(docker exec -i "$c" besu public-key export-address \
    --node-private-key-file=/opt/besu/data/key 2>/dev/null | grep "^0x" | tail -1 | tr -d '\r\n')

  # Obtener la public key del nodo
  PUBKEY=$(docker exec -i "$c" besu public-key export \
    --node-private-key-file=/opt/besu/data/key 2>/dev/null | grep "^0x" | tail -1 | tr -d '\r\n')

  # Imprimir tabla
  sENODE=$(shorten_enode "$ENODE")
  sADDR=$(shorten "$ADDRESS")
  sPUB=$(shorten "$PUBKEY")
  printf " %-15s | %-25s | %-11s | %-11s \n" "$c" "$sENODE" "$sPUB" "$sADDR"
done
