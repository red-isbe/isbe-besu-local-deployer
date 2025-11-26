# Automatized Besu Docker Deployer by parameters

This project provides an automated, Docker-based deployment of a Hyperledger Besu QBFT network, allowing you to quickly spin up a configurable private blockchain without installing Besu locally. 

All configuration —such as number of validators, Besu version, chain ID, block time, and network IP—

These parameters can be set interactively or left at defaults, making it easy for both beginners and advanced users to deploy, test, and manage a Besu network entirely in Docker:
- Number of validators
- Besu version
- Elliptic Curve (EC)
- Chain ID
- Block time
- Network IP

This tool is developed for Linux terminal, if you are running this in Windows under WSL, you will need to execute a cleaner tool that make scripts compatible first ($ dos2unix * config/*)

There is a [Troubleshooting section](#troubleshooting) also if you have some problem


### Pre-Requisites

🟡 Docker and Docker-compose installed 

🟡 jq installed ($ apt-get install jq)

🟡 Docker running 


### DEPLOYMENT

To deploy and make it work for conversational mode, simply run the installation script (you may review it beforehand if you wish): 🙋🏻‍♂️

```bash
bash install.sh      
```

For NO conversational (batch mode) it is possible to avoid prompting. It uses default configuration.
You can run the installer non-interactively with the `-b` or `--batch` flag:
```bash
bash install.sh -b
```

Ready ✅

To stop the network and clean the installation just run:
```bash
bash clean.sh      
```

DONE 😎



Optional
-----

### ➡️ Pre-funding custom accounts

If you want to add custom accounts with an initial balance to the network built with Besu, you must do so **before generating the genesis.json**.
This is achieved by editing the `qbftConfigFile.json` file in the `alloc` section.

This is an example:

    "alloc": {
      "0x1234567890abcdef1234567890abcdef12345678": {
        "balance": "1000000000000000000000000000"
      },

### ➡️ Plugins Installation

If you want to use some plugin, you can add the jar file in the plugins folder (/plugins) and they will be mounted in the besu container.
To do that you will need to modify the pom.xml file to add the dependency of the plugin you want to use, and then run:

```bash
cd plugins/<your-plugin-folder>
mvn clean package
```

You will need to move the jar file from the target folder to the plugins folder:
```bash
mv target/<your-plugin-jar-file>.jar plugins/
```

Later, you can see that the plugin is loaded in the besu logs when you start the nodes.
```
# Plugin Registration Summary:
# Registered Plugins:
#  - HelloPlugin (hello-plugin/1.0-SNAPSHOT)
# TOTAL = 1 of 1 plugins successfully registered.
```
Also, you can find an example of a plugin in the plugins/hello-plugin folder.


### ➡️ Geth console


🟡 First if you want access to the geth console you need to install first:
```bash
apt-get install geth
```
(or brew install geth)

Then run the Node Console
```bash
geth attach http://localhost:8545
```
Where we can exec commands like
```bash
eth.chainId()
eth.blockNumber
eth.getTransactionFromBlock(555)
web3.eth.getBalance("0x<direccion_de_tu_cuenta>", (err, balance) => { console.log(balance); });
web3.version
admin.peers
exit
```

Also calls directly through curl like:
```bash
curl -X POST --data '{"jsonrpc":"2.0",curl -X POST --data '{"jsonrpc":"2.0","method":"eth_getBalance","params":["0x<YourAccountAddress>", "latest"],"id":1}' http://0.0.0.0:8545
```
 

### ➡️ Light Explorer + Node Validator Managment

You can use the explorer folder to run a light explorer that will connect to your besu node and show you some information about the network.
It is automatically configured to connect to the besu node running in localhost:8545 and with all the validators that you have configured in the installation.

Go to the explorer folder:
```bash
cd explorer
``` 

Now you can run once:
```bash
npm install
```

And then to run the explorer:
```bash
npm run dev
```

This will create the explorer service in http://localhost:25000

There you can see the blocks, transactions, and validators of your network.

### ➡️ Node Information

You can run the nodeInfo.sh script to see the information of the nodes in the network
So you can see the enode, public key and address of each node.

```bash
bash nodeInfo.sh
```
### ➡️ Stop and Resume Network

If you want to stop the network and resume it later, you can use the following commands:

To stop the network, you can use:

```bash
docker stop $(docker ps --filter label=project=besu -q)
```

To resume the network, you can use:

```bash  
docker start $(docker ps -a --filter label=project=besu -q)
```

In the meantime you can reallocate resources in your machine, and when you want to use the network again, just resume it with the command above, maintaining all the data and state of the network.

### ➡️ Network Export / Import

1. Export any running deployment (optional `-f` sets the zip name under `exports/`):
  ```bash
  bash exportNetwork.sh [-f my-network.zip]
  ```
  - Packages `config/`, `QBFT-Network/`, `plugins/`, and `metadata.json`; prompts before stopping containers to keep data consistent.
2. Import a zip (required `-f` points to the archive to restore):
  ```bash
  bash importNetwork.sh -f exports/my-network.zip
  ```
  - Overwrites existing `config/`, `QBFT-Network/`, and `plugins/`, recreates the Docker network, and relaunches bootnode plus validators.
3. After import the containers stay up; check with `docker ps --filter label=project=besu` or run `clean.sh` to start from scratch.


### ➡️Troubleshooting
---------------

- If you have problems with execute permissions
```bash
chmod +x install.sh clean.sh
```

-  For general error, try to clean all your old files first

```bash
bash clean.sh      
```

- If you have some conflict with containers that are already under us, you can exec: (will drop any stopped container ⚠️)
```bash
docker container prune
docker network prune
```

- If you want to see which validators contains the extradata field in genesis.json

First set that field in a extradata.txt in your PWD (just the 0x in your file):

```bash
curl -s -X POST http://localhost:8545 -H "Content-Type: application/json" --data '{"jsonrpc":"2.0","method":"eth_getBlockByNumber","params":["160", false],"id":1}' | jq -r '.result.extraData' > extradata.txt
```

Then decode it with besu docker image (you can change the version if you want):

```bash
docker run --rm -v "$(pwd):/opt/besu/data" hyperledger/besu:25.9.0 rlp decode --from=/opt/besu/data/extradata.txt --type=QBFT_EXTRA_DATA
```

Exportes need zip