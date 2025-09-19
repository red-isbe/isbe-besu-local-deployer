# Besu Local Deployer with Docker Compose

Este proyecto permite desplegar una red local de Besu con consenso QBFT usando Docker Compose para una gestión simplificada.

## Requisitos Previos

- Docker y Docker Compose instalados.
- Bash (en Windows, usa WSL o Git Bash).
- jq instalado (para manipulación de JSON).

## Instalación

1. Clona el repositorio:

   ```bash
   git clone https://github.com/alastria/isbe-besu-local-deployer.git
   cd isbe-besu-local-deployer
   ```

2. Ejecuta el script de instalación:

   ```bash
   bash install.sh [opciones]
   ```

### Opciones de `install.sh`

- `-n <num_nodes>`: Número de nodos (mínimo 4, máximo 100). Default: 4
- `-v <besuVersion>`: Versión de Besu. Default: 24.12.2
- `-c <chainId>`: ID de la cadena. Default: 2222
- `-b <blockperiodseconds>`: Segundos entre bloques. Default: 2
- `-e <ellipticCurve>`: Curva elíptica (secp256k1 o secp256r1). Default: secp256k1
- `-i <ip>`: Máscara IP base (ej. 172.16.241). Default: 172.16.241
- `-y`: Modo no interactivo (usa defaults sin preguntar).

Ejemplos:

- `bash install.sh` → Usa defaults, pide confirmación.
- `bash install.sh -n 5 -v 24.12.3 -y` → 5 nodos, versión custom, no interactivo.

### Qué hace `install.sh`

1. Verifica Docker.
2. Si hay contenedores Besu corriendo, pide confirmación para detenerlos (a menos que `-y`).
3. Limpia contenedores y directorios previos.
4. Genera configuración de genesis y claves con Besu.
5. Crea `docker-compose.yml` dinámicamente con servicios para bootnode y validadores.
6. Inicia el bootnode con `docker-compose up -d bootnode`.
7. Espera a que el bootnode esté listo (RPC responde).
8. Obtiene el enode del bootnode y actualiza `configValidators.toml`.
9. Inicia todos los validadores con `docker-compose up -d`.

Al final, tendrás una red Besu corriendo con nodos conectados.

## Gestión con Docker Compose

Una vez instalado, usa comandos de Docker Compose para gestionar:

- Ver estado de contenedores:

  ```bash
  docker-compose ps
  ```

- Ver logs:

  ```bash
  docker-compose logs [servicio]  # ej. docker-compose logs bootnode
  ```

- Detener la red:

  ```bash
  docker-compose stop
  ```

- Reiniciar:

  ```bash
  docker-compose start
  ```

## Limpieza

Para detener y limpiar todo:

```bash
bash clean.sh
```

Esto ejecuta `docker-compose down -v`, elimina directorios y redes.

## Archivos Importantes

- `install.sh`: Script de instalación.
- `clean.sh`: Script de limpieza.
- `docker-compose.yml`: Generado dinámicamente, define servicios.
- `config/`: Configuraciones de Besu.
- `QBFT-Network/`: Datos de nodos.

## Solución de Problemas

- **Error de red**: Si hay solapamiento de subnets, cambia el IP con `-i`.
- **Contenedores no inician**: Verifica logs con `docker-compose logs`.
- **Enode no encontrado**: Asegúrate de que el bootnode esté corriendo y RPC accesible.

## Migración desde versión anterior

La versión anterior usaba `docker run` manual. Esta usa Compose para mejor gestión. Ejecuta `bash clean.sh` para limpiar antes de migrar.
