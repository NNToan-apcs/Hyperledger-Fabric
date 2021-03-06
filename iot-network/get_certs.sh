#!/bin/bash
# $DIRECTORY_ORG1=~/Hyperledger/toan-fabric-network/iot-network/connection/org1
# $DIRECTORY_ORG2=~/Hyperledger/toan-fabric-network/iot-network/connection/org2
# if [ ! -d "$DIRECTORY_ORG1" ]; then
#     mkdir connection/org1
# fi
# if [ ! -d "$DIRECTORY_ORG2" ]; then
#     mkdir connection/org2

# fi
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.iot.net/peers/peer0.org1.iot.net/tls/ca.crt > connection/org1/ca-peer0-org1.txt
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt > connection/org2/ca-peer0-org2.txt
awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/iot.net/orderers/orderer.iot.net/tls/ca.crt > connection/ca-orderer.txt

export ORG1=crypto-config/peerOrganizations/org1.iot.net/users/Admin@org1.iot.net/msp

cp -p $ORG1/signcerts/A*.pem ~/Hyperledger/toan-fabric-network/iot-network/connection/org1
rm -rf ~/Hyperledger/toan-fabric-network/iot-network/connection/org1/*_sk
cp -p $ORG1/keystore/*_sk  ~/Hyperledger/toan-fabric-network/iot-network/connection/org1

export ORG2=crypto-config/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp

cp -p $ORG2/signcerts/A*.pem  ~/Hyperledger/toan-fabric-network/iot-network/connection/org2
rm -rf ~/Hyperledger/toan-fabric-network/iot-network/connection/org2/*_sk
cp -p $ORG2/keystore/*_sk  ~/Hyperledger/toan-fabric-network/iot-network/connection/org2
