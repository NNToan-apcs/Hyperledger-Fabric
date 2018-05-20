# IoT Network (IOTN)
Reference:
(https://github.com/CATechnologies/blockchain-tutorials/wiki/Tutorial:-Hyperledger-Fabric-v1.1-%E2%80%93-Create-a-Development-Business-NeTwork-on-zLinux)


Add downloaded binaries to your PATH environment variable so that these can be picked up without fully qualifying the path to each binary:
```
#export PATH=~/Hyperledger/toan-fabric-network/bin:$PATH
export PATH=~/Hyperledger-Fabric/bin:$PATH
```

# Using script
To bring up network
```
./byfn -m up
```
To bring down network
```
./byfn -m down
```

To extend the network (Add org3 to the network)
```
./eyfn -m up
```
# Using commands
## Create Hyperledger Fabric Business Network

To generate certificates, run the following command:
```
cryptogen generate --config=./crypto-config.yamlryptogen generate --config=./crypto-config.yaml
```
## Create channel.tx and the Genesis Block Using the configtxgen tool

To create orderer genesis block, run the following commands:

```
export FABRIC_CFG_PATH=$PWD
mkdir channel-artifacts
configtxgen -profile TwoOrgsOrdererGenesis -outputBlock ./channel-artifacts/genesis.block
```
To create channel configuration transaction using configtxgen: (http://hyperledger-fabric.readthedocs.io/en/release-1.1/commands/configtxgen.html)

```
export CHANNEL_NAME=mychannel
configtxgen -profile TwoOrgsChannel -outputCreateChannelTx ./channel-artifacts/channel.tx -channelID $CHANNEL_NAME
```
Define anchor peers for each organization
```
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org1MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org1MSP
configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate ./channel-artifacts/Org2MSPanchors.tx -channelID $CHANNEL_NAME -asOrg Org2MSP
```
## Start the Hyperledger Fabric blockchain network

```
export CHANNEL_NAME=mychannel
CHANNEL_NAME=$CHANNEL_NAME docker-compose -f docker-compose-cli.yaml up -d
```
## The channel

Enter the CLI container using the following command:
```
docker exec -it cli bash  (peer0 of Org1 is the default one in CLI container --> no need certs)
```
Peer1 of Org1:
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/users/Admin@org1.iot.net/msp
CORE_PEER_ADDRESS=peer1.org1.iot.net:7051
CORE_PEER_LOCALMSPID="Org1MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/peers/peer1.org1.iot.net/tls/ca.crt
```
Peer0 of Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp
CORE_PEER_ADDRESS=peer0.org2.iot.net:7051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt
```
Peer1 of Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp
CORE_PEER_ADDRESS=peer1.org2.iot.net:7051
CORE_PEER_LOCALMSPID="Org2MSP"
CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer1.org2.iot.net/tls/ca.crt
```

### Create channel
```
export CHANNEL_NAME=mychannel
peer channel create -o orderer.iot.net:7050 -c $CHANNEL_NAME -f ./channel-artifacts/channel.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem
```
You should see mychannel.block by type 'ls' in command

### Join channel (default peer)
```
peer channel join -b mychannel.block
```
### Join channel (Other peers)
Peer1 of Org1
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/users/Admin@org1.iot.net/msp CORE_PEER_ADDRESS=peer1.org1.iot.net:7051 CORE_PEER_LOCALMSPID="Org1MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/peers/peer1.org1.iot.net/tls/ca.crt peer channel join -b mychannel.block
```
Peer0 of Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer0.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt peer channel join -b mychannel.block
```
Peer1 of Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer1.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer1.org2.iot.net/tls/ca.crt peer channel join -b mychannel.block
```
## CLI logs (another terminal)
```
docker logs peer0.org1.iot.net
```

## Update anchor peers
export CHANNEL_NAME=mychannel
Orderer
```
peer channel update -o orderer.iot.net:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org1MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem
```
Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer0.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt peer channel update -o orderer.iot.net:7050 -c $CHANNEL_NAME -f ./channel-artifacts/Org2MSPanchors.tx --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem
```

## Chaincode
### Deploy chaincode on each peer using the following command:
```
peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```
In order to let other peers from other organizations to interact with the ledger as well, we need to install chaincode there as well.
Peer1 of Org1:
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/users/Admin@org1.iot.net/msp CORE_PEER_ADDRESS=peer1.org1.iot.net:7051 CORE_PEER_LOCALMSPID="Org1MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/peers/peer1.org1.iot.net/tls/ca.crt peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```
Peer0 of Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer0.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```
Peer1 of Org2
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer1.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer1.org2.iot.net/tls/ca.crt peer chaincode install -n mycc -v 1.0 -p github.com/chaincode/chaincode_example02/go/
```

### Instantiate chaincode

To instantiate the chaincode from one of the peers: 
```
    - a=100, b=200 for each org
    - endorsement policy for our channel: ('Org1MSP.member','Org2MSP.member')
peer chaincode instantiate -o orderer.iot.net:7050 --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem -C $CHANNEL_NAME -n mycc -v 1.0 -c '{"Args":["init","a", "100", "b","200"]}' -P "OR ('Org1MSP.member','Org2MSP.member')"
```

## Execute tutorial scenario

Query for initial state of the ledger
```
export CHANNEL_NAME=mychannel
peer chaincode query -C $CHANNEL_NAME -n mycc -c '{"Args":["query","a"]}'
```
## Invoke chaincode
Start with peer0 of Org1:
```
peer chaincode invoke -o orderer.iot.net:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
``` 

Peer1 of Org1:
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/users/Admin@org1.iot.net/msp CORE_PEER_ADDRESS=peer1.org1.iot.net:7051 CORE_PEER_LOCALMSPID="Org1MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org1.iot.net/peers/peer1.org1.iot.net/tls/ca.crt peer chaincode invoke -o orderer.iot.net:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
```
Peer0 of Org2:
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer0.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt peer chaincode invoke -o orderer.iot.net:7050  --tls --cafile /opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/ordererOrganizations/iot.net/orderers/orderer.iot.net/msp/tlscacerts/tlsca.iot.net-cert.pem  -C $CHANNEL_NAME -n mycc -c '{"Args":["invoke","a","b","10"]}'
```
Peer1 of Org2:
```
CORE_PEER_MSPCONFIGPATH=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp CORE_PEER_ADDRESS=peer1.org2.iot.net:7051 CORE_PEER_LOCALMSPID="Org2MSP" CORE_PEER_TLS_ROOTCERT_FILE=/opt/gopath/src/github.com/hyperledger/fabric/peer/crypto/peerOrganizations/org2.iot.net/peers/peer1.org2.iot.net/tls/ca.crt peer chaincode invoke -o orderer.iot.net:7050  --tls 
```