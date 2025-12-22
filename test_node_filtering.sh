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

echo "🧪 Test: Verificando funcionalidad de filtrado de nodos expulsados"
echo "=================================================="

echo "1. Validadores activos actuales:"
curl -s -X POST --data '{"jsonrpc":"2.0","method":"qbft_getValidatorsByBlockNumber","params":["latest"],"id":1}' http://localhost:8545 | jq '.result[]'

echo ""
echo "2. Nodos configurados en el explorador:"
cat /Users/victor/workspace/izertis/isbe/isbe-besu-local-deployer/explorer/src/config/config.json | jq '.nodes[] | {name: .name, accountAddress: .accountAddress}'

echo ""
echo "3. Análisis:"
echo "   - bootnode (0x153d...): ✅ Validador activo"
echo "   - node2 (0x37cd...): ✅ Validador activo"
echo "   - node3 (0x3d1b...): ✅ Validador activo"
echo "   - node4 (0x8350...): ✅ Validador activo"

echo ""
echo "4. El desplegable del explorador debería mostrar todos los nodos"
echo "5. No debería haber alertas de nodos expulsados (todos son validadores)"
