#   GUÍA DE COMPILACIÓN PARA RED BESU secp256r1

##   **DATOS DE RED**
```
Chain ID: 2222
RPC URL: http://localhost:8545
 
```

##   **DERIVACIÓN DE CLAVE (CRÍTICO)**
```javascript
// 🚨 USAR EXACTAMENTE ESTE MÉTODO:
const { p256 } = require('@noble/curves/p256');  // ✅ CORRECTO
const { keccak_256 } = require('@noble/hashes/sha3');

const privateKeyBytes = new Uint8Array(Buffer.from('CLAVE-PRIVADA', 'hex'));
const publicKeyPoint = p256.getPublicKey(privateKeyBytes, false); // ✅ false = uncompressed
const publicKeyWithoutPrefix = publicKeyPoint.slice(1);
const hash = keccak_256(publicKeyWithoutPrefix);
const address = '0x' + Buffer.from(hash.slice(-20)).toString('hex');
 
```

##  **CONFIGURACIÓN DE COMPILACIÓN**

### 1. Versión Solidity:
```bash
npm install solc@0.8.19 --save-dev  #   EXACTA - NO más nueva
```

### 2. Configuración JSON:
```json
{
  "language": "Solidity",
  "sources": {
    "contract.sol": { "content": "..." }
  },
  "settings": {
    "optimizer": {
      "enabled": false,         // 🚨 CRÍTICO: OFF
      "runs": 1
    },
    "evmVersion": "shanghai",   // 🚨 CRÍTICO: Shanghai
    "viaIR": false,            // 🚨 CRÍTICO: NO IR
    "outputSelection": {
      "*": {
        "*": ["abi", "evm.bytecode.object"]
      }
    }
  }
}
```

### 3. Comando de Compilación:
```bash
npx solc --optimize-runs 1 --evm-version shanghai contracts/YourContract.sol --combined-json abi,bin
```

##   **VALIDACIÓN DE BYTECODE**
```javascript
function validateBytecode(bytecode) {
    const bytecodeSize = (bytecode.length - 2) / 2;
    
    if (bytecodeSize > 24576) { // 24KB límite
        throw new Error('Bytecode muy grande');
    }
    
    if (!bytecode.startsWith('0x')) {
        throw new Error('Bytecode debe empezar con 0x');
    }
    
    return true;
}
```

##   **PARÁMETROS DE TRANSACCIÓN**
```javascript
const txParams = {
    from: '0x6b..',
    data: bytecode,
    gas: '0x7A1200',      // 8M gas
    gasPrice: '0x3E8',    // 1000 wei
    nonce: '0x0',         // Verificar nonce actual
    chainId: '0x8AE'      // 2222 en hex
};
```

##  *REGLAS CRÍTICAS**
- ✅ Solidity 0.8.19 (NO 0.8.20+)
- ✅ Optimizer OFF
- ✅ evmVersion "shanghai" 
- ✅ viaIR false
- ✅ Bytecode < 24KB
- ✅ Gas límite 8M+
- ✅ Noble Curves p256 (NO nist)

---
 