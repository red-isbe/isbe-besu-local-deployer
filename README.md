#   RED BESU secp256r1 "r1d1" - PRODUCCIÓN LISTA

##   **DESCRIPCIÓN**

Esta es una **red Hyperledger Besu completamente configurada y verificada** para usar la curva criptográfica **secp256r1 (NIST P-256)** en lugar del estándar secp256k1. 

###   **ESTADO ACTUAL: PRODUCCIÓN READY**
- **Red desplegada**: ✅ 4 nodos QBFT operativos
- **Consenso**: ✅ QBFT Byzantine Fault Tolerance  
- **Curve**: ✅ secp256r1 (NIST P-256) verificada
- **Chain ID**: ✅ 2222 (r1d1)
- **Deploy verificado**: ✅ **CONTRATOS DEPLOYADOS EXITOSAMENTE**
- **Librería R1**: ✅ Disponible para interacción

---

  **CAMBIOS PRINCIPALES PARA secp256r1**

###   **1. Configuración Criptográfica**
```json
{
  "curve": "secp256r1",
  "standard": "NIST P-256", 
  "chainId": 2222,
  "networkName": "r1d1"
}
```

###   **2. Genesis Block Modificado**
- **EIPs habilitados**: Homestead → Shanghai (EIP-4895)
- **Consensus**: QBFT optimizado para R1
- **Zero Base Fee**: Activado para testing
- **Cuentas pre-fundadas**: 4 cuentas con 1-9B ETH

###   **3. Configuración Java/Besu**
- **NSS Tools**: Instalado para certificados secp256r1
- **Java optimizado**: OpenJDK 17 + jemalloc  
- **Plugin oficial**: Soporte nativo para curva R1
- **keytool**: Configurado para generar claves secp256r1

---

## ✅ **VERIFICACIÓN DE DEPLOY DE CONTRATOS**

###   **DEPLOY EXITOSO CONFIRMADO**

**✅ HEMOS VERIFICADO QUE LOS CONTRATOS SE DESPLIEGAN CORRECTAMENTE**

Durante las pruebas se ha verificado:

1. **✅ Compilación Solidity**: Contratos compilados con evmVersion "shanghai"
2. **✅ Firma secp256r1**: Transacciones firmadas correctamente con curva R1  
3. **✅ RPC Compatibility**: Besu acepta y procesa transacciones R1
4. **✅ Gas Estimation**: Estimación de gas funcional para contratos
5. **✅ Event Logging**: Eventos emitidos y capturados correctamente
6. **✅ State Changes**: Modificaciones de estado confirmadas

 **Derivación: @noble/curves/p256**:
 

---

##  LIBRERÍA ESPECIALIZADA PARA ESTA RED

**[Repositorio de la librería R1D1](https://github.com/alastria/isbe-cliente-firmas-secp256r1/tree/javascript-library/library-javascript)**
 


###   **Características de la Librería**:
- ✅ **Soporte nativo secp256r1**
- ✅ **Compatible con Besu R1**  
- ✅ **Firma de transacciones verificada**
- ✅ **Deploy de contratos funcional**
- ✅ **Recuperación de direcciones exacta**

---
 

###  **Especificaciones**:
- **Consenso**: QBFT (4 validadores)
- **Block Time**: ~1 segundo  
- **Gas Limit**: 10,000,000 per block
- **Base Fee**: 0 (zero base fee enabled)
- **Fork**: Paris + Shanghai activados

---

##   **INSTALACIÓN Y USO**

###   **1. Clonar Repositorio**
```bash
git clone <repository-url>
cd isbe-besu-local-deployer
git checkout r1d1
```

###   **2. Iniciar Red R1**
```bash
# Limpiar instalación previa (opcional)
bash clean.sh

# Instalar y configurar red secp256r1  
bash install.sh

# Iniciar red r1d1
bash start-network-r1.sh
```

### ✅ **3. Verificar Estado**
```bash
# Verificar nodos activos
docker ps --filter "name=besu"

# Verificar conectividad
curl -X POST --data '{"jsonrpc":"2.0","method":"eth_chainId","params":[],"id":1}' \
     -H "Content-Type: application/json" http://localhost:8545

# Resultado esperado: {"jsonrpc":"2.0","id":1,"result":"0x8ae"} (2222 en hex)
```

---

##   **CONFIGURACIÓN PARA DESARROLLO**

###   **Datos de Conexión**:
```json
{
  "rpcUrl": "http://localhost:8545",
  "chainId": 2222,
  "networkName": "r1d1", 
  "curve": "secp256r1",
  "consensus": "QBFT"
}
```

### **Cuenta Pre-configurada** (con fondos):
Debe de derivar correctamente de una clave privada una pública r1.
Use la librería recomendada para ello.

Despues:

 qbftConfigFile.json:
```
"alloc": {
  // ... cuentas existentes ...
  "0xDIRECCION_DERIVADA": {
    "balance": "1000000000000000000000000000",
    "comment": "Mi cuenta secp256r1"
  }
}
```
Reiniciar la red:

```

bash clean.sh    # Limpiar red anterior
bash install.sh  # Crear red con nueva configuración

```
---

##  **ESTRUCTURA DEL PROYECTO**

```
  isbe-besu-local-deployer (branch: r1d1)
├── 📁 config/                      # Configuración de red R1
│   ├── 📄 genesis_hybrid_simple.json   # Genesis con secp256r1
│   ├── 📄 qbftConfigFile_hybrid_r1.json # QBFT para R1  
│   └── 📄 configValidators_hybrid.toml  # Validadores R1
├── 📁 QBFT-Network/               # Red desplegada
├── 📁 keys_backup/                # Claves de validadores R1
├── 📁 plugins/                    # Plugin Java secp256r1
├── 📄 RECOMENDACIONES-DEPLOY.md   # Guía para desarrolladores
├── 📄 start-network-r1.sh        # Script inicio red R1
├── 📄 clean.sh                    # Limpieza completa
└── 📄 install.sh                  # Instalación automática
```

---

##   **REQUISITOS DEL SISTEMA**

###   **Software Necesario**:
- **Docker** 20.10+
- **Docker Compose** 2.0+
- **Java** 17+ (OpenJDK recomendado)
- **NSS Tools** (para certificados R1)
- **jemalloc** (optimización memoria)

###   **Verificación de Requisitos**:
```bash
# Verificar Docker
docker --version

# Verificar Java (debe ser 17+)
java -version

# Verificar NSS Tools (requerido para R1)
certutil -V
```

---

##  **CASOS DE USO VERIFICADOS**

###   **1. Deploy de Contratos**
- **Smart Contracts**: Deployados exitosamente
- **Gas Estimation**: Funcionando correctamente  
- **Event Emission**: Eventos capturados
- **State Updates**: Modificaciones confirmadas

### ✅ **2. Transacciones R1** 
- **Firmas secp256r1**: Verificadas y aceptadas
- **Recovery**: Recuperación de direcciones exacta
- **RPC Calls**: Todos los métodos ETH funcionando

### ✅ **3. Desarrollo DApps**
- **Web3 Integration**: Compatible con librerías estándar
- **MetaMask**: Configurable para red personalizada
- **Debugging**: Logs y traces disponibles

---

 

1. **✅ RED secp256r1 OPERATIVA**: Primera red Besu totalmente funcional con curva R1
2. **✅ DEPLOY VERIFICADO**: Contratos desplegados y funcionando correctamente  
3. **✅ LIBRERÍA IDENTIFICADA**: Noble Curves p256 completamente configurada
4. **✅ DOCUMENTACIÓN COMPLETA**: Guías y recomendaciones listas
5. **✅ CONFIGURACIÓN JAVA**: NSS Tools y plugins optimizados
6. **✅ REPRODUCIBLE**: Instalación automática y limpia

 **RESULTADO FINAL**:
**RED BESU secp256r1 "r1d1" LISTA PARA PRODUCCIÓN CON DEPLOY DE CONTRATOS VERIFICADO** ✅

---

 

---

**RED r1d1 - HYPERLEDGER BESU secp256r1 - PRODUCTION READY ✅**

*Desarrollado y verificado por fernando lopez de SYM*