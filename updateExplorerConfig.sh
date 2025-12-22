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

echo "🔄 Actualizando configuración del explorador con direcciones actuales..."

# Obtener las direcciones actuales de los nodos
NODE_INFO=$(bash nodeInfo.sh | tail -n +4)

# Extraer direcciones
BOOTNODE_ADDR=$(echo "$NODE_INFO" | grep "bootnode" | awk '{print $NF}')
NODE2_ADDR=$(echo "$NODE_INFO" | grep "node2" | awk '{print $NF}')
NODE3_ADDR=$(echo "$NODE_INFO" | grep "node3" | awk '{print $NF}')
NODE4_ADDR=$(echo "$NODE_INFO" | grep "node4" | awk '{print $NF}')

# Crear nueva configuración
cat > explorer/src/config/config.json << EOF
{
  "algorithm": "qbft",
  "nodes": [
    {
      "name": "bootnode",
      "client": "besu",
      "rpcUrl": "http://127.0.0.1:8545",
      "privateTxUrl": "",
      "accountAddress": "$BOOTNODE_ADDR"
    },
    {
      "name": "node2",
      "client": "besu",
      "rpcUrl": "http://127.0.0.1:8546",
      "privateTxUrl": "",
      "accountAddress": "$NODE2_ADDR"
    },
    {
      "name": "node3",
      "client": "besu",
      "rpcUrl": "http://127.0.0.1:8547",
      "privateTxUrl": "",
      "accountAddress": "$NODE3_ADDR"
    },
    {
      "name": "node4",
      "client": "besu",
      "rpcUrl": "http://127.0.0.1:8548",
      "privateTxUrl": "",
      "accountAddress": "$NODE4_ADDR"
    }
  ]
}
EOF

echo "✅ Configuración actualizada:"
echo "   - bootnode: $BOOTNODE_ADDR"
echo "   - node2: $NODE2_ADDR"
echo "   - node3: $NODE3_ADDR"
echo "   - node4: $NODE4_ADDR"

echo ""
echo "🎯 El explorador ahora debería mostrar todos los nodos en el desplegable."
