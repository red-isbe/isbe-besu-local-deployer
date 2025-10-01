# RED BESU total secp256r1 "r1d1" 

## DESCRIPCIÓN

Red Hyperledger Besu configurada para usar curva criptográfica **secp256r1 (NIST P-256)** en lugar de secp256k1 totalmente funcional.

## ESTADO ACTUAL
- **Nombre**: r1d1
- **Red desplegada**: 4 nodos QBFT operativos
- **Consenso**: QBFT Byzantine Fault Tolerance  
- **Curva**: secp256r1 (NIST P-256) verificada
- **Chain ID**: 2222 
- **EVM**: Cancun/Deneb/Prague activados
- **Solidity**: Soporte ^0.8.28
- **Arquitectura ISBE**: Contratos desplegables

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

## INSTALACIÓN Y USO

### Nota importante sobre reinicio
Esta red está optimizada para **instalación rápida**, no para reinicios parciales. El script `install.sh` regenera la red completa en ~30 segundos.

### 1. Clonar repositorio
```bash
git clone <repository-url>
cd isbe-besu-local-deployer
git checkout r1d1
```

### 2. Instalación y arranque
```bash
# Instalar y levantar red secp256r1  
bash install.sh

# Responder 'n' para usar configuración por defecto
```

### 3. Reinicio completo
```bash
# Limpiar y reinstalar (método recomendado)
bash clean.sh
bash install.sh
```

### 4. Comandos Docker directos (uso avanzado)
```bash
# Parar contenedores temporalmente
docker stop bootnode node2 node3 node4

# Reiniciar contenedores (puede requerir configuración adicional)
docker start bootnode node2 node3 node4
```

### 5. Verificar estado
```bash
# Verificar contenedores
docker ps

# Verificar conectividad
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545

# Resultado esperado: {"jsonrpc":"2.0","id":1,"result":"0x8ae"}
```

## SCRIPTS DISPONIBLES

| Script | Función | Tiempo aprox |
|--------|---------|--------------|
| `install.sh` | Instalación completa | ~30 segundos |
| `clean.sh` | Limpieza total | ~5 segundos |
docker ps --filter "name=besu"

# Verificar conectividad
```
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545
```



### qbftConfigFile.json 
```
{
  "genesis": {
    "nonce": "0x0",
    "timestamp": "0x0",
    "extraData": "0xf8a4a00000000000000000000000000000000000000000000000000000000000000000f87e94e4d2cced4cd6d9f963eeba9d0038b546e2376e6a94d60203fcd65cf1472ee22277dce9fb5fd41f171e946174365d69c09b040476ac6a76f5af4e469750d59403fab32bf53d712b7e3ba456a2d0d1ff1a6b054094a41af77b076d8c9d415cad1917e3cd9ce25b75d8949978504d6d370e6d0f1ef1fab1ac12ddbde4b186c080c0",
    "gasLimit": "0x1fffffffffffff",
    "gasUsed": "0x0",
    "number": "0x0",
    "difficulty": "0x1",
    "coinbase": "0x0000000000000000000000000000000000000000",
    "mixHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "parentHash": "0x0000000000000000000000000000000000000000000000000000000000000000",
    "config": {
      "chainId": 2222,
      "networkName": "r1d1",
      "description": "ISBE Besu secp256r1 Network - Diamond Architecture Ready",
      "contractSizeLimit": 24576,
      "homesteadBlock": 0,
      "eip150Block": 0,
      "eip150Hash": "0x0000000000000000000000000000000000000000000000000000000000000000",
      "eip155Block": 0,
      "eip158Block": 0,
      "byzantiumBlock": 0,
      "constantinopleBlock": 0,
      "petersburgBlock": 0,
      "istanbulBlock": 0,
      "muirglacierblock": 0,
      "berlinBlock": 0,
      "londonBlock": 0,
      "parisBlock": 0,
      "shanghaiBlock": 0,
      "cancunBlock": 0,
      "denebBlock": 0,
      "pragueBlock": 0,
      "zeroBaseFee": true,
      "ecCurve": "secp256r1",
      "qbft": {
        "blockperiodseconds": 2,
        "epochlength": 1000,
        "requesttimeoutseconds": 2
      },
      "ellipticCurve": "secp256r1"
    },
    "alloc": {
      "0xbebd29124435700f87a3821dc95eea8ab95fcb1b": {
        "balance": "1000000000000000000000000000"
      },
      "0xcbac250151088ae5137039d4b0b10f0a8d55ea42": {
        "balance": "1000000000000000000000000000"
      },
      "0x56db16fa6e201d894db6a158999eda03b94b4a7d": {
        "balance": "1000000000000000000000000000"
      },
      "0x52b1f2380d94b25f1dece54b0cc8d8b1c5990cc8": {
        "balance": "1000000000000000000000000000"
      },
      "0x19a005cf2ad7e7a88b41a9b8208b0c374123efdf": {
        "balance": "1000000000000000000000000000"
      },
      "0xa58ede5c366a3398c6863325a83af2074990db5c": {
        "balance": "1000000000000000000000000000"
      },
      "0x049bEe05040C428aB767d5582eEC159EB5a9de75": {
        "balance": "1000000000000000000000000000"
      },
      "0x1a179f6dfcfaff34b4f045dd0d50a7b426233726": {
        "balance": "1000000000000000000000000000",
        "comment": "secp256r1 account for deployment"
      },
      "0xdB11FEfA99BfD167ace7D73057909Afe9b2068C0": {
        "balance": "1000000000000000000000000000",
        "comment": "secp256r1 account #2"
      },
      "0x6b5be277e2ddf8bbf6193205cb84cca3ab8576bc": {
        "balance": "9000000000000000000000000000",
        "comment": "secp256r1 account #3"
      }
    }
  },
  "blockchain": {
    "nodes": {
      "generate": true,
      "count": 4
    }
  }
}


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

### Contratos desplegados (pruebas en local)
| Use Case | Type | Address |
|----------|------|---------|
| ERC20 Complete | Erc20 | 0x4e7ccaD4E283bf451934A3f07cA29828E2CDB8fD |
| DID Registry | Did_registry | 0x66D6Ff552f726069184Fbc95B30eb3e5d67B906D |
| ERC721 | Erc721 | 0xA65f82248F6fB44B2A6F80f5361657caa792eB74 |
| Hash Timestamp | Hash_timestamp | 0x47015DA2f9A58b29C063406C860b33D0e807fc41 |

## LIBRERÍAS SECP256R1:

1. **Repositorio**: [isbe-cliente-firmas-secp256r1](https://github.com/alastria/isbe-cliente-firmas-secp256r1/tree/javascript-library/library-javascript)

2. **Librería Secp256r1Wallet.js en isbe-contracts ya disponible para despliegue desde hardhat**


## ESTRUCTURA DEL PROYECTO

```
isbe-besu-local-deployer/
├── config/
│   ├── configBootnode.toml          # Config bootnode
│   ├── configValidators.toml        # Config validadores
│   ├── qbftConfigFile.json          # Configuración QBFT secp256r1
│   └── qbftConfigFile.json.backup   # Backup configuración
├── QBFT-Network/                    # Red desplegada (generada por install.sh)
│   └── networkFiles/                # Datos nodos (blockchain, keys, logs)
├── keys_backup/                     # Backup claves validadores
│   ├── enode_keys/                  # Claves enodes
│   └── validator_keys/              # Claves secp256r1 validadores
├── plugins/
│   └── hello-plugin/                # Plugin Java secp256r1
├── docs/
│   ├── artifacts/                   # Artefactos ISBE
│   ├── besu-docs.md                 # Documentación Besu
│   ├── elliptic.md                  # Info elliptic curves
│   ├── noble-curves.md              # Noble curves
│   ├── noble-hashes.md              # Noble hashes
│   └── RECOMENDACIONES-DEPLOY.md    # Guía técnica deploy
├── createValidatorNodes.sh          # Generación nodos
├── getEnode.sh                      # Obtener enodes
├── moveKeys.sh                      # Mover claves
├── install.sh                       # Instalación y arranque
├── clean.sh                         # Limpieza completa
└── README.md                        # Este archivo
```

## CASOS DE USO VERIFICADOS

### Deploy de contratos
- Smart Contracts: Solidity ^0.8.28 deployados
- Diamond Architecture: 23 business logics sin fallos
- EVM Features: Cancun/Deneb/Prague opcodes funcionando
- Gas Estimation: Automática 

*Desarrollado y verificado por Fernando Lopez de SYM*
 
