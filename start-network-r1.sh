#!/bin/bash
#
# RED HYPERLEDGER BESU secp256r1 (R1) - CONFIGURACIÓN COMPLETA
# ==========================================================
# 
# - QBFT Consensus con 4 validadores R1
# - Soporte Paris + Shanghai
# - Chain ID: 2222
# - ZeroBaseFee habilitado
# - Puerto RPC: 8545 expuesto
# - Soporte completo para contratos R1
#

set -e

echo "🚀 INICIANDO RED BESU secp256r1 (R1) NETWORK"
echo "============================================"
echo "🔐 Curva: secp256r1 (NIST P-256)"
echo "⚡ Consensus: QBFT"
echo "🌐 Chain ID: 2222"
echo "💰 Gas: Zero Base Fee"
echo "🔗 EVM: Paris + Shanghai"
echo ""

# Configuración
NETWORK_NAME="besu-r1-network"
BASE_PORT=8545
BASE_P2P_PORT=30303
BESU_VERSION="25.9.0"

# Colores para output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Verificar Docker
if ! command -v docker &> /dev/null; then
    error "Docker no está instalado"
    exit 1
fi

# Limpiar contenedores existentes
log "🧹 Limpiando contenedores previos..."
docker stop $(docker ps -q --filter "name=besu") 2>/dev/null || true
docker rm $(docker ps -aq --filter "name=besu") 2>/dev/null || true

# Crear red Docker
log "🌐 Creando red Docker: $NETWORK_NAME"
docker network create $NETWORK_NAME 2>/dev/null || warning "Red $NETWORK_NAME ya existe"

# Limpiar y crear directorio de red
log "📁 Preparando estructura de directorios..."
rm -rf QBFT-Network
mkdir -p QBFT-Network
mkdir -p QBFT-Network/logs

# Generar configuración de red QBFT R1
log "⚙️  Generando configuración QBFT secp256r1..."
docker run --rm \
  -v $(pwd)/config:/config \
  -v $(pwd)/QBFT-Network:/opt/besu/QBFT-Network \
  hyperledger/besu:$BESU_VERSION \
  operator generate-blockchain-config \
  --config-file=/config/qbftConfigFile_hybrid_r1.json \
  --to=/opt/besu/QBFT-Network \
  --private-key-file-name=key

success "✅ Configuración R1 generada"

# Mostrar direcciones de validadores
log "🔍 Direcciones de validadores secp256r1:"
for i in {0..3}; do
    if [ -f "QBFT-Network/keys/0x$(cat QBFT-Network/keys/validator-$i-address)" ]; then
        addr=$(cat QBFT-Network/keys/validator-$i-address)
        echo "  Validator-$((i+1)): 0x$addr"
    fi
done

# Iniciar nodos validadores
log "🚀 Iniciando nodos validadores..."

for i in {0..3}; do
    node_name="besu-validator-$((i+1))"
    rpc_port=$((BASE_PORT + i))
    p2p_port=$((BASE_P2P_PORT + i))
    
    log "Iniciando $node_name en puerto RPC $rpc_port"
    
    docker run -d \
      --name $node_name \
      --network $NETWORK_NAME \
      -p $rpc_port:$rpc_port \
      -p $p2p_port:$p2p_port \
      -v $(pwd)/QBFT-Network/keys/validator-$i:/opt/besu/keys \
      -v $(pwd)/QBFT-Network/networkFiles/genesis.json:/opt/besu/genesis.json \
      -v $(pwd)/QBFT-Network/logs:/opt/besu/logs \
      hyperledger/besu:$BESU_VERSION \
      --data-path=/opt/besu/data \
      --genesis-file=/opt/besu/genesis.json \
      --node-private-key-file=/opt/besu/keys/key \
      --rpc-http-enabled \
      --rpc-http-api=ADMIN,ETH,NET,WEB3,TXPOOL,DEBUG \
      --rpc-http-host=0.0.0.0 \
      --rpc-http-port=$rpc_port \
      --rpc-http-cors-origins="*" \
      --rpc-ws-enabled \
      --rpc-ws-api=ADMIN,ETH,NET,WEB3,TXPOOL,DEBUG \
      --rpc-ws-host=0.0.0.0 \
      --rpc-ws-port=$((rpc_port + 1000)) \
      --p2p-port=$p2p_port \
      --discovery-enabled=false \
      --bootnodes-file=/opt/besu/networkFiles/static-nodes.json \
      --min-gas-price=0 \
      --logging=DEBUG \
      --log-level=INFO
done

# Esperar a que los nodos se inicializen
log "⏳ Esperando inicialización de nodos..."
sleep 15

# Verificar estado de la red
log "🔍 Verificando estado de la red..."
echo ""
echo "📊 ESTADO DE LA RED R1:"
echo "======================="

for i in {0..3}; do
    node_name="besu-validator-$((i+1))"
    rpc_port=$((BASE_PORT + i))
    
    if docker ps --format "{{.Names}}" | grep -q "^$node_name$"; then
        echo "✅ $node_name: EJECUTÁNDOSE (Puerto RPC: $rpc_port)"
        
        # Verificar conexión RPC
        response=$(curl -s -X POST \
            --data '{"jsonrpc":"2.0","method":"net_peerCount","params":[],"id":1}' \
            -H "Content-Type: application/json" \
            http://localhost:$rpc_port 2>/dev/null || echo "error")
            
        if [[ "$response" != "error" ]]; then
            peers=$(echo $response | grep -o '"result":"[^"]*"' | cut -d'"' -f4 | xargs printf "%d" 2>/dev/null || echo "0")
            echo "   🌐 Peers conectados: $peers"
        fi
    else
        echo "❌ $node_name: ERROR"
    fi
done

echo ""
echo "🎯 ENDPOINTS DISPONIBLES:"
echo "========================"
echo "🔗 RPC Principal: http://localhost:8545"
echo "🔗 WebSocket Principal: http://localhost:9545"
echo "🌐 Chain ID: 2222"
echo "💰 Gas Config: Zero Base Fee"
echo "🔐 Signature Algorithm: secp256r1 (NIST P-256)"
echo ""
echo "📡 ENDPOINTS RPC ADICIONALES:"
for i in {0..3}; do
    echo "   Validator-$((i+1)): http://localhost:$((BASE_PORT + i))"
done

echo ""
echo "🧪 PRUEBA DE CONECTIVIDAD:"
echo "curl -X POST --data '{\"jsonrpc\":\"2.0\",\"method\":\"eth_chainId\",\"params\":[],\"id\":1}' -H \"Content-Type: application/json\" http://localhost:8545"

echo ""
success "🎉 Red Besu secp256r1 iniciada exitosamente!"
echo ""
echo "📚 PRÓXIMOS PASOS:"
echo "  1. Generar claves R1: ./tools/generate-r1-keys.sh"
echo "  2. Configurar cuentas: ./scripts/setup-r1-accounts.js"
echo "  3. Deploy contratos: ./scripts/deploy-contract-r1.js"
echo ""
echo "📁 Logs en: QBFT-Network/logs/"
echo "🔑 Keys en: QBFT-Network/keys/"