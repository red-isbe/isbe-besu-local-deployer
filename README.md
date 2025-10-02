# Hyperledger Besu secp256r1 Network Deployer

Despliegue automatizado de red Hyperledger Besu QBFT con soporte nativo para curva criptográfica **secp256r1 (NIST P-256)** mediante Docker.

Este proyecto permite levantar rápidamente una blockchain privada configurable sin necesidad de instalar Besu localmente. Todos los parámetros (número de validadores, versión de Besu, Chain ID, tiempo de bloque, IP de red) pueden configurarse interactivamente o usar valores por defecto.

## CARACTERÍSTICAS

- ✅ **Red desplegada**: 4 nodos QBFT operativos (configurable)
- ✅ **Consenso**: QBFT Byzantine Fault Tolerance  
- ✅ **Curva**: secp256r1 (NIST P-256) - **Soporte nativo en Besu 25.9.0**
- ✅ **Chain ID**: 2222 (r1d1)
- ✅ **EVM**: Cancun/Deneb/Prague activados desde bloque 0
- ✅ **Solidity**: ^0.8.28 compatible
- ✅ **Zero Base Fee**: Habilitado para desarrollo
- ✅ **Arquitectura ISBE**: Diamond pattern completamente funcional

## CONFIGURACIÓN TÉCNICA

### Red
```json
{
  "rpcUrl": "http://127.0.1:8545",
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

## PRE-REQUISITOS

### Obligatorios

🟡 **Docker y Docker-compose instalados**
```bash
# Verificar instalación
docker --version          # Debe ser 20.10+
docker-compose --version

# Linux - Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
newgrp docker

# Verificar que Docker está corriendo
docker info
```

🟡 **jq instalado** (procesamiento JSON)
```bash
sudo apt-get install jq
```

🟡 **Docker corriendo**
```bash
# Iniciar Docker si está detenido
sudo systemctl start docker
sudo systemctl enable docker
```

### Herramientas adicionales para secp256r1

**NSS Tools** (Network Security Services)
```bash
# Linux/Ubuntu
sudo apt install libnss3-tools

# macOS
brew install nss

# Verificar instalación
certutil -h
```

**Java 17+** (para desarrollo/debugging)
```bash
sdk install java 21.0.3-tem 
sdk use java 21.0.3-tem
java -version  # Verificar versión
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

### Compatibilidad WSL (Windows)

Si ejecutas en Windows bajo WSL, necesitas convertir los scripts primero:
```bash
sudo apt install dos2unix
dos2unix *.sh config/*
```

## DESPLIEGUE

Para desplegar y poner en marcha la red, simplemente ejecuta el script de instalación:

```bash
bash install.sh
```

✅ **¡Listo!**

Para detener la red y limpiar completamente la instalación:

```bash
bash clean.sh
```

😎 **DONE**

### Instalación paso a paso

#### 1. Clonar repositorio
```bash
git clone https://github.com/alastria/isbe-besu-local-deployer.git
cd isbe-besu-local-deployer
git checkout r1d1
```

#### 2. Instalación y arranque
```bash
# Instalar y levantar red secp256r1  
bash install.sh

# Configuración interactiva:
# - Responder 'n' para usar configuración por defecto
# - Responder 'y' para personalizar número de nodos, chain ID, etc.
```

**Configuración por defecto:**
- 4 nodos validadores
- Besu 25.9.0 (con soporte secp256r1 nativo)
- Curva elíptica: secp256r1
- Chain ID: 2222
- Tiempo de bloque: 2 segundos
- Red IP: 172.16.240.0/24

#### 3. Reinicio completo de la red

Esta red está optimizada para **instalación rápida** (~30 segundos), no para reinicios parciales:

```bash
# Método recomendado: limpiar y reinstalar
bash clean.sh
bash install.sh
```

#### 4. Comandos Docker directos (uso avanzado)

```bash
# Parar contenedores temporalmente
docker stop bootnode node2 node3 node4

# Reiniciar contenedores (puede requerir reconfiguración)
docker start bootnode node2 node3 node4

# Ver contenedores activos
docker ps --filter "name=besu"
```

## VERIFICACIÓN

### Estado de la red

```bash
# Verificar contenedores Docker
docker ps

# Resultado esperado: 4 contenedores (bootnode, node2, node3, node4)
```

### Conectividad RPC

```bash
# Verificar Chain ID
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545

# Resultado esperado: {"jsonrpc":"2.0","id":1,"result":"0x8ae"}  # 2222 en hex

# Obtener número de bloque
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545

# Balance de cuenta prefunded
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x1a179f6dfcfaff34b4f045dd0d50a7b426233726","latest"],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545
```

### Geth Console (opcional)

**Instalación de Geth:**
```bash
# Linux/Ubuntu
sudo apt-get install geth

# macOS
brew install geth
```

**Conectar a la consola:**
```bash
geth attach http://localhost:8545
```

**Comandos útiles:**
```javascript
eth.chainId()
eth.blockNumber
eth.getTransactionFromBlock(555)
web3.eth.getBalance("0x1a179f6dfcfaff34b4f045dd0d50a7b426233726", (err, balance) => { 
  console.log(balance); 
});
web3.version
admin.peers
exit
```

## CONFIGURACIÓN AVANZADA

### Pre-funding cuentas personalizadas

Si deseas añadir cuentas con balance inicial, edita `config/qbftConfigFile.json` **ANTES** de ejecutar `install.sh`:

```json
"alloc": {
  "0x1234567890abcdef1234567890abcdef12345678": {
    "balance": "1000000000000000000000000000",
    "comment": "Mi cuenta personalizada"
  }
}
```

### Plugins de Besu (opcional)

Para usar plugins personalizados:

1. **Añade el JAR** al directorio `plugins/`:
```bash
cp tu-plugin.jar plugins/
```

2. **El plugin se montará automáticamente** en los contenedores Besu en `/opt/besu/plugins`

3. **Verifica que el plugin se cargó:**
```bash
docker logs bootnode | grep -i plugin

# Output esperado:
# Plugin Registration Summary:
# Registered Plugins:
#  - YourPlugin (your-plugin/1.0.0)
# TOTAL = 1 of 1 plugins successfully registered.
```

**Ejemplo de plugin disponible:**
```
plugins/hello-plugin/    # Plugin de ejemplo (no necesario para secp256r1)
```

### Parámetros configurables en install.sh

Durante la instalación interactiva puedes configurar:

| Parámetro | Valor por defecto | Descripción |
|-----------|-------------------|-------------|
| Número de validadores | 4 | Nodos QBFT validadores |
| Versión Besu | 25.9.0 | **Requerido para secp256r1** |
| Curva elíptica | secp256r1 | secp256k1 o secp256r1 |
| Chain ID | 2222 | Identificador de la red |
| Block time | 2s | Tiempo entre bloques |
| Network IP | 172.16.240.0/24 | Subred Docker |

## SOPORTE secp256r1

### ⚠️ IMPORTANTE: Versión de Besu

El soporte para **secp256r1 (NIST P-256)** está **integrado nativamente** en **Hyperledger Besu 25.9.0+**.

**NO se requiere ningún plugin externo.** El soporte viene incluido en:

1. **Hyperledger Besu 25.9.0** - Versión con soporte R1 built-in
2. **Genesis Configuration** - Activación mediante `"ecCurve": "secp256r1"`
3. **NSS Libraries** - Funciones criptográficas NIST P-256

### Stack tecnológico secp256r1

```
┌─────────────────────────────────────────┐
│  Hyperledger Besu 25.9.0+               │ ← Soporte nativo secp256r1
│  (Docker: hyperledger/besu:25.9.0)      │
├─────────────────────────────────────────┤
│  NSS Libraries (libnss3-tools)          │ ← Criptografía NIST P-256
├─────────────────────────────────────────┤
│  Genesis Config                         │ ← "ecCurve": "secp256r1"
│  (qbftConfigFile.json)                  │
└─────────────────────────────────────────┘
```

### Verificación de secp256r1

```bash
# 1. Verificar que Besu 25.9.0 está en uso
docker exec bootnode besu --version
# Output: besu/v25.9.0/...

# 2. Verificar curva en el genesis generado
jq '.config.ecCurve' QBFT-Network/networkFiles/genesis.json
# Output: "secp256r1"

# 3. Ver logs de validación de curva
docker logs bootnode | grep -i "secp256r1\|elliptic"
```

### Librería de firmas secp256r1

**Repositorio**: [isbe-cliente-firmas-secp256r1](https://github.com/alastria/isbe-cliente-firmas-secp256r1/tree/javascript-library/library-javascript)

La librería `Secp256r1Wallet.js` está disponible en el repositorio **isbe-contracts** y proporciona:

- ✅ Soporte nativo secp256r1 en JavaScript/TypeScript
- ✅ Compatible con Besu R1
- ✅ Firma de transacciones verificada
- ✅ Deploy de contratos funcional
- ✅ Basada en `@noble/curves` (p256)

## CONFIGURACIÓN DE RED

### Parámetros principales

| Parámetro | Valor | Descripción |
|-----------|-------|-------------|
| **RPC URL** | http://127.0.0.1:8545 | Endpoint JSON-RPC del bootnode |
| **Chain ID** | 2222 (0x8ae) | Identificador único de la red r1d1 |
| **Network Name** | r1d1 | Nombre de la red |
| **Consensus** | QBFT | Byzantine Fault Tolerance |
| **Block Time** | 2 segundos | Tiempo entre bloques |
| **Gas Price** | 0 | Sin costo de gas (desarrollo) |
| **Gas Limit** | 0x1fffffffffffff | Prácticamente ilimitado |
| **Elliptic Curve** | secp256r1 | NIST P-256 |
| **EVM Version** | Cancun/Deneb/Prague | Activado desde bloque 0 |
| **Solidity** | ^0.8.28 | Versión compatible |

### Cuentas pre-funded

La red incluye varias cuentas con balance inicial (ejemplo):

```javascript
// Account secp256r1 para deployment
address: "0x1a179f6dfcfaff34b4f045dd0d50a7b426233726"
balance: "1000000000000000000000000000" // 1 billion ETH

// Account secp256r1 #3 (main)
address: "0x6b5be277e2ddf8bbf6193205cb84cca3ab8576bc"
balance: "9000000000000000000000000000" // 9 billion ETH
```

Ver todas las cuentas en `config/qbftConfigFile.json` sección `alloc`.

### Configuración Hardhat

```javascript
// hardhat.config.js
module.exports = {
  networks: {
    r1d1: {
      url: "http://127.0.0.1:8545",
      chainId: 2222,
      gasPrice: 0,
      blockGasLimit: 0x1fffffffffffff,
      timeout: 60000,
      accounts: {
        mnemonic: "tu mnemonic aquí"
      }
    }
  },
  solidity: {
    version: "0.8.28",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  }
};
```

## ARQUITECTURA DIAMOND ISBE

### Deploy exitoso confirmado

```
Total duration: 315921ms (315.92s)
Signature curve: secp256r1
Completed steps: 4/4
Business logics: 23 successful, 0 failed
Use cases: 4 successful, 0 failed
```

### Contratos desplegados (pruebas en local)

| Use Case | Type | Address |
|----------|------|---------|
| ERC20 Complete | Erc20 | 0x4e7ccaD4E283bf451934A3f07cA29828E2CDB8fD |
| DID Registry | Did_registry | 0x66D6Ff552f726069184Fbc95B30eb3e5d67B906D |
| ERC721 | Erc721 | 0xA65f82248F6fB44B2A6F80f5361657caa792eB74 |
| Hash Timestamp | Hash_timestamp | 0x47015DA2f9A58b29C063406C860b33D0e807fc41 |

### Casos de uso verificados

- ✅ Smart Contracts Solidity ^0.8.28 deployados exitosamente
- ✅ Diamond Architecture: 23 business logics sin fallos
- ✅ EVM Features: Cancun/Deneb/Prague opcodes funcionando
- ✅ Gas Estimation: Automática y precisa
- ✅ Event Emission: Capturados correctamente
- ✅ Firmas secp256r1: Verificadas por consenso QBFT
- ✅ Recovery: Recuperación exacta de direcciones
- ✅ Zero Gas Fee: Sin costo para desarrollo

## ESTRUCTURA DEL PROYECTO

```
isbe-besu-local-deployer/
├── config/
│   ├── configBootnode.toml          # Configuración bootnode
│   ├── configValidators.toml        # Configuración validadores
│   ├── qbftConfigFile.json          # Configuración QBFT secp256r1
│   └── qbftConfigFile.json.backup   # Backup configuración
├── QBFT-Network/                    # Red desplegada (generada por install.sh)
│   └── networkFiles/                # Datos nodos (blockchain, keys, logs)
├── keys_backup/                     # Backup claves validadores
│   ├── enode_keys/                  # Claves enodes
│   └── validator_keys/              # Claves secp256r1 validadores
├── plugins/
│   └── hello-plugin/                # Plugin ejemplo (no requerido para R1)
├── docs/
│   ├── artifacts/                   # Artefactos ISBE
│   ├── besu-docs.md                 # Documentación Besu
│   ├── elliptic.md                  # Info elliptic curves
│   ├── noble-curves.md              # Noble curves
│   ├── noble-hashes.md              # Noble hashes
│   └── RECOMENDACIONES-DEPLOY.md    # Guía técnica deploy
├── createValidatorNodes.sh          # Generación nodos validadores
├── getEnode.sh                      # Obtener enodes de nodos
├── moveKeys.sh                      # Mover claves entre directorios
├── install.sh                       # Script principal de instalación
├── clean.sh                         # Limpieza completa de la red
└── README.md                        # Este archivo
```

## SCRIPTS DISPONIBLES

| Script | Función | Tiempo aprox |
|--------|---------|--------------|
| `install.sh` | Instalación completa de la red | ~30 segundos |
| `clean.sh` | Limpieza total (contenedores, volúmenes, datos) | ~5 segundos |
| `createValidatorNodes.sh` | Crea nodos validadores QBFT | Llamado por install.sh |
| `getEnode.sh` | Obtiene enode URLs de los nodos | Uso manual |
| `moveKeys.sh` | Mueve claves de validadores | Uso manual |

## TROUBLESHOOTING

### Red no levanta

```bash
# 1. Verificar Docker está corriendo
docker info

# 2. Limpiar y reintentar
bash clean.sh
bash install.sh
```

### Errores de conexión WSL

```bash
# Convertir line endings
dos2unix *.sh config/*
```

### Ver logs de un nodo

```bash
docker logs bootnode
docker logs node2
docker logs node3
docker logs node4

# Seguir logs en tiempo real
docker logs -f bootnode
```

### Problemas de puertos

```bash
# Verificar que puertos 8545-8549 están libres
netstat -tulpn | grep 854

# Liberar puerto si está en uso
sudo fuser -k 8545/tcp
```

---

**Desarrollado y verificado por Fernando Lopez de SYM**  
**Arquitectura ISBE implementada con soporte Solidity ^0.8.28**

*Basado en el proyecto [Besu Docker Deployer](https://github.com/alastria/besu-docker-deployer)*

 
