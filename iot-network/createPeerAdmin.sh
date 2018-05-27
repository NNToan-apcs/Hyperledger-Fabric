#!/bin/bash
composer card create -p ~/Hyperledger/toan-fabric-network/iot-network/connection/org1/toan-network-org1.json -u PeerAdmin -c ~/Hyperledger/toan-fabric-network/iot-network/connection/org1/Admin@org1.iot.net-cert.pem -k ~/Hyperledger/toan-fabric-network/iot-network/connection/org1/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@toan-network-org1.card
composer card create -p ~/Hyperledger/toan-fabric-network/iot-network/connection/org2/toan-network-org2.json -u PeerAdmin -c ~/Hyperledger/toan-fabric-network/iot-network/connection/org2/Admin@org2.iot.net-cert.pem -k ~/Hyperledger/toan-fabric-network/iot-network/connection/org2/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@toan-network-org2.card

composer card delete -c PeerAdmin@toan-network-org1
composer card delete -c PeerAdmin@toan-network-org2

composer card import -f PeerAdmin@toan-network-org1.card --card PeerAdmin@toan-network-org1
composer card import -f PeerAdmin@toan-network-org2.card --card PeerAdmin@toan-network-org2