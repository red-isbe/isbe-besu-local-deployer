# RED BESU secp256r1 "r1d1" - PRODUCCIÓN

## DESCRIPCIÓN

Red Hyperledger Besu configurada para usar curva criptográfica **secp256r1 (NIST P-256)** en lugar de secp256k1. Incluye soporte EVM moderno y arquitectura Diamond ISBE completamente desplegada.

## ESTADO ACTUAL

- **Red desplegada**: 4 nodos QBFT operativos
- **Consenso**: QBFT Byzantine Fault Tolerance  
- **Curva**: secp256r1 (NIST P-256) verificada
- **Chain ID**: 2222 (r1d1)
- **EVM**: Cancun/Deneb/Prague activados
- **Solidity**: Soporte ^0.8.28
- **Arquitectura ISBE**: Diamond pattern completamente desplegada

## REQUISITOS DEL SISTEMA

### Obligatorios

**NSS Tools**
```bash
# Linux/Ubuntu
sudo apt install libnss3-tools

# macOS
brew install nss
```

**Java 17+**
```bash
sdk install java 21.0.3-tem 
sdk use java 21.0.3-tem
java -version  # Verificar versión
```

**Docker**
```bash
docker --version  # Debe ser 20.10+
```

### Configuración NSS Database
```bash
mkdir nssdb
echo "test123" > nsspin.txt
certutil -N -d sql:nssdb -f nsspin.txt
touch ./nssdb/secmod.db

cat <<EOF >./nss.cfg
name = NSScrypto-r1d1
nssSecmodDirectory = ./nssdb
nssDbMode = readOnly
nssModule = keystore
showInfo = true
EOF
```

## INSTALACIÓN

### 1. Clonar repositorio
```bash
git clone <repository-url>
cd isbe-besu-local-deployer
git checkout r1d1
```

### 2. Iniciar red
```bash
# Limpiar instalación previa
bash clean.sh

# Instalar y configurar red secp256r1  
bash install.sh

# Responder 'n' para usar configuración por defecto
```

### 3. Verificar estado
```bash
# Verificar contenedores
docker ps --filter "name=besu"

# Verificar conectividad
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545
```

## CONFIGURACIÓN TÉCNICA

### Red
```json
{
  "rpcUrl": "http://localhost:8545",
  "chainId": 2222,
  "networkName": "r1d1",
  "curve": "secp256r1",
  "consensus": "QBFT",
  "evmVersion": "cancun",
  "solidityVersion": "^0.8.28",
  "gasPrice": 0,
  "blockTime": "2s"
}
```

### Genesis configuración
- **Cancun/Deneb/Prague**: Activados desde bloque 0
- **Zero Base Fee**: Habilitado para desarrollo
- **Gas Limit**: 0x1fffffffffffff (prácticamente ilimitado)
- **Elliptic Curve**: secp256r1
- **Block Period**: 2 segundos

### Cuentas preconfiguradas
```
0x1a179f6dfcfaff34b4f045dd0d50a7b426233726  # 1000 ETH (deployment)
0xdB11FEfA99BfD167ace7D73057909Afe9b2068C0  # 1000 ETH (testing)
0x6b5be277e2ddf8bbf6193205cb84cca3ab8576bc  # 9000 ETH (whale)
```

## CONFIGURACIÓN HARDHAT

### hardhat.config.js
```javascript
require("@nomicfoundation/hardhat-toolbox");

module.exports = {
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: { enabled: true, runs: 200 },
      evmVersion: "cancun"
    }
  },
  networks: {
    besu_r1: {
      url: "http://localhost:8545",
      chainId: 2222,
      accounts: { mnemonic: "YOUR_MNEMONIC_HERE" },
      gasPrice: 0,
      gas: 50000000,
      blockGasLimit: 0x1fffffffffffff,
      timeout: 60000,
      allowUnlimitedContractSize: true
    }
  }
};
```

### Comandos básicos
```bash
# Instalar dependencias
npm install --save-dev hardhat @nomicfoundation/hardhat-toolbox

# Deploy
npx hardhat run scripts/deploy.js --network besu_r1

# Console
npx hardhat console --network besu_r1
```

## ARQUITECTURA DIAMOND ISBE DESPLEGADA

### Deploy exitoso confirmado
```
Total duration: 315921ms (315.92s)
Signature curve: secp256r1
Completed steps: 4/4
Business logics: 23 successful, 0 failed
Use cases: 4 successful, 0 failed
```

### Contratos desplegados
| Use Case | Type | Address |
|----------|------|---------|
| ERC20 Complete | Erc20 | 0x4e7ccaD4E283bf451934A3f07cA29828E2CDB8fD |
| DID Registry | Did_registry | 0x66D6Ff552f726069184Fbc95B30eb3e5d67B906D |
| ERC721 | Erc721 | 0xA65f82248F6fB44B2A6F80f5361657caa792eB74 |
| Hash Timestamp | Hash_timestamp | 0x47015DA2f9A58b29C063406C860b33D0e807fc41 |

## LIBRERÍA SECP256R1

**Repositorio**: [isbe-cliente-firmas-secp256r1](https://github.com/alastria/isbe-cliente-firmas-secp256r1/tree/javascript-library/library-javascript)

### Características
- Soporte nativo secp256r1
- Compatible con Besu R1
- Firma de transacciones verificada
- Deploy de contratos funcional
- Recuperación de direcciones exacta

### Uso con Noble Curves
```javascript
import { p256 } from '@noble/curves/p256';

const privateKey = "tu_clave_privada_hex";
const publicKey = p256.getPublicKey(privateKey);
const address = // derivar dirección desde public key
```

## ESTRUCTURA DEL PROYECTO

```
isbe-besu-local-deployer (branch: r1d1)
├── config/                      # Configuración de red R1
│   ├── genesis.json             # Genesis generado con secp256r1
│   ├── qbftConfigFile.json      # QBFT para R1  
│   └── configValidators.toml    # Validadores R1
├── QBFT-Network/               # Red desplegada
├── keys_backup/                # Claves de validadores R1
├── plugins/                    # Plugin Java secp256r1
├── start-network-r1.sh        # Script inicio red R1
├── clean.sh                    # Limpieza completa
└── install.sh                  # Instalación automática
```

## CASOS DE USO VERIFICADOS

### Deploy de contratos
- Smart Contracts: Solidity ^0.8.28 deployados
- Diamond Architecture: 23 business logics sin fallos
- EVM Features: Cancun/Deneb/Prague opcodes funcionando
- Gas Estimation: Automática y perfecta
- Event Emission: Capturados sin problemas
- State Updates: Confirmadas en blockchain

### Transacciones secp256r1
- Firmas secp256r1: Verificadas por consenso
- Recovery: Recuperación exacta de direcciones
- RPC Calls: Todos los métodos ETH funcionando
- Noble Curves: Librería p256 integrada
- Zero Gas Fee: Sin costo para desarrollo

### Desarrollo DApps
- Hardhat Integration: WSL optimizado
- Web3 Compatibility: Librerías estándar
- MetaMask Ready: Red personalizada configurable
- Debugging: Logs, traces disponibles
- WSL Support: Acceso nativo desde Windows

## TROUBLESHOOTING

### Error: secp256r1 no funciona
```bash
# Verificar NSS Tools
certutil -V

# Verificar Java
java -version  # Debe ser 17+

# Verificar configuración
grep -i secp256r1 config/genesis.json
```

### Error: Contenedores no inician
```bash
# Limpiar completamente
bash clean.sh
sudo docker system prune -f

# Reinstalar
bash install.sh
```

### Error: No se puede conectar
```bash
# Verificar puertos
netstat -tlnp | grep :8545

# Verificar contenedores
docker logs bootnode
```

---

**RED r1d1 - HYPERLEDGER BESU secp256r1 - ARQUITECTURA ISBE COMPLETA**

*Desarrollado y verificado por Fernando Lopez de SYM*
*Arquitectura ISBE implementada con soporte Solidity ^0.8.28*
