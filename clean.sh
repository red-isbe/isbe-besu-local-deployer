#!/bin/bash

echo "Stopping and removing Docker containers using 'hyperledger/besu' image... "

docker ps -a --filter "label=project=besu" -q | xargs -r docker stop
docker ps -a --filter "label=project=besu" -q | xargs -r docker rm

echo "Cleaning QBFT-Network directory content..."
if [ -d "QBFT-Network" ]; then
  find QBFT-Network -mindepth 1 ! -name ".gitkeep" -exec rm -rf {} +
fi
echo "Deleting config/genesis.json..."
rm -f config/genesis.json

# Attempt to remove any Docker networks that collide with the configured IP base.
# We determine the IP base from config/qbftConfigFile.json if available, otherwise
# fall back to the common default used by this project.
IP_BASE_FALLBACK="172.16.240"
IP_BASE="${IP_BASE_FALLBACK}"
if [ -f config/qbftConfigFile.json ] && command -v jq >/dev/null 2>&1; then
  read -r ip_val < <(jq -r '.blockchain.nodes.ip // empty' config/qbftConfigFile.json 2>/dev/null || true)
  if [ -n "$ip_val" ]; then
    IP_BASE="$ip_val"
  fi
fi

echo "Looking for Docker networks that may overlap IP base: $IP_BASE"
IFS='.' read -r _o1 _o2 _o3 <<<"$IP_BASE"
PREFIX_2="${_o1}.${_o2}"

for nid in $(docker network ls -q); do
  sub=$(docker network inspect -f '{{range .IPAM.Config}}{{.Subnet}}{{end}}' "$nid" 2>/dev/null || true)
  name=$(docker network inspect -f '{{.Name}}' "$nid" 2>/dev/null || true)
  if [ -z "$sub" ]; then
    continue
  fi
  # If the network subnet begins with the same two octets (e.g. 172.16.*), consider it
  if [[ "$sub" == ${PREFIX_2}.* ]]; then
    # Skip built-in networks
    case "$name" in
      bridge|host|none)
        echo "Skipping built-in network $name ($sub)"
        continue
        ;;
    esac

    echo "Found potentially overlapping network: $name ($sub)"
    # List containers attached to this network
    containers=$(docker network inspect -f '{{range $k,$c := .Containers}}{{$k}} {{end}}' "$nid" 2>/dev/null || true)
    if [ -z "$containers" ]; then
      echo "  No containers attached -> removing network $name"
      docker network rm "$name" >/dev/null 2>&1 || true
      continue
    fi

    # If containers exist, only remove network if all attached containers are part of this project
    removable=true
    for cid in $containers; do
      # Get label 'project' for the container
      proj=$(docker inspect -f '{{index .Config.Labels "project"}}' "$cid" 2>/dev/null || true)
      if [[ "$proj" != "besu" ]]; then
        removable=false
        echo "  Container $cid is not labeled project=besu (label=$proj). Will not auto-remove network $name."
        break
      fi
    done

    if $removable; then
      echo "  All attached containers labeled project=besu -> stopping and removing them, then removing network $name"
      for cid in $containers; do
        docker stop "$cid" >/dev/null 2>&1 || true
        docker rm -f "$cid" >/dev/null 2>&1 || true
      done
      docker network rm "$name" >/dev/null 2>&1 || true
    fi
  fi
done

if docker network inspect besu-network >/dev/null 2>&1; then
  echo "Removing old Docker network 'besu-network'..."
  docker network rm besu-network >/dev/null 2>&1 || true
fi

echo "Cleanup complete."
