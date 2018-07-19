#!/bin/bash
#make dir if not exists
mkdir -p connection/org1
mkdir -p connection/org2

#variables
HOST=grpcs://localhost
CURRENT_DIR=$PWD
CONNECTION_ORG1=connection/org1
CONNECTION_ORG2=connection/org2
CHANNEL_NAME=toanchannel
#ORG1
TLS_CA_ORG1=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org1.iot.net/peers/peer0.org1.iot.net/tls/ca.crt) 

#ORG2
TLS_CA_ORG2=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/peerOrganizations/org2.iot.net/peers/peer0.org2.iot.net/tls/ca.crt)

#Orderer
TLS_CA_ORDERER=$(awk 'NF {sub(/\r/, ""); printf "%s\\n",$0;}' crypto-config/ordererOrganizations/iot.net/orderers/orderer.iot.net/tls/ca.crt)

#Get admins
export ORG1=crypto-config/peerOrganizations/org1.iot.net/users/Admin@org1.iot.net/msp

cp -p $ORG1/signcerts/A*.pem $CONNECTION_ORG1
rm -rf $CONNECTION_ORG1/*_sk
cp -p $ORG1/keystore/*_sk  $CONNECTION_ORG1

export ORG2=crypto-config/peerOrganizations/org2.iot.net/users/Admin@org2.iot.net/msp

cp -p $ORG2/signcerts/A*.pem  $CONNECTION_ORG2
rm -rf $CONNECTION_ORG2/*_sk
cp -p $ORG2/keystore/*_sk  $CONNECTION_ORG2

#create connection files

rm -rf $CONNECTION_ORG1/toan-network-org1.json
rm -rf $CONNECTION_ORG2/toan-network-org2.json
cat << EOF > $CONNECTION_ORG1/toan-network-org1.json
{
    "name": "$CHANNEL_NAME",
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "abc": {
            "orderers": [
                "orderer.iot.net"
            ],
            "peers": {
                "peer0.org1.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.iot.net",
                "peer1.org1.iot.net"
            ],
            "certificateAuthorities": [
                "ca.org1.iot.net"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.iot.net",
                "peer1.org2.iot.net"
            ],
            "certificateAuthorities": [
                "ca.org2.iot.net"
            ]
        }
    },
    "orderers": {
        "orderer.iot.net": {
            "url": "$HOST:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORDERER"
            }
        }
    },
    "peers": {
        "peer0.org1.iot.net": {
            "url": "$HOST:7051",
            "eventUrl": "$HOST:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG1"
            }
        },
        "peer1.org1.iot.net": {
            "url": "$HOST:8051",
            "eventUrl": "$HOST:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG1"
            }
        },
        "peer0.org2.iot.net": {
            "url": "$HOST:9051",
            "eventUrl": "$HOST:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG2"
            }
        },
        "peer1.org2.iot.net": {
            "url": "$HOST:10051",
            "eventUrl": "$HOST:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG2"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.iot.net": {
            "url": "https://localhost:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.iot.net": {
            "url": "https://localhost:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

cat << EOF > $CONNECTION_ORG2/toan-network-org2.json
{
    "name": "toan-network",
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "Org2",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "$CHANNEL_NAME": {
            "orderers": [
                "orderer.iot.net"
            ],
            "peers": {
                "peer0.org1.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer0.org2.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org2.iot.net": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.iot.net",
                "peer1.org1.iot.net"
            ],
            "certificateAuthorities": [
                "ca.org1.iot.net"
            ]
        },
        "Org2": {
            "mspid": "Org2MSP",
            "peers": [
                "peer0.org2.iot.net",
                "peer1.org2.iot.net"
            ],
            "certificateAuthorities": [
                "ca.org2.iot.net"
            ]
        }
    },
    "orderers": {
        "orderer.iot.net": {
            "url": "$HOST:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORDERER"
            }
        }
    },
    "peers": {
        "peer0.org1.iot.net": {
            "url": "$HOST:7051",
            "eventUrl": "$HOST:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG1"
            }
        },
        "peer1.org1.iot.net": {
            "url": "$HOST:8051",
            "eventUrl": "$HOST:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG1"
            }
        },
        "peer0.org2.iot.net": {
            "url": "$HOST:9051",
            "eventUrl": "$HOST:9053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org2.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG2"
            }
        },
        "peer1.org2.iot.net": {
            "url": "$HOST:10051",
            "eventUrl": "$HOST:10053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org2.iot.net"
            },
            "tlsCACerts": {
                "pem": "$TLS_CA_ORG2"
            }
        }
    },
    "certificateAuthorities": {
        "ca.org1.iot.net": {
            "url": "https://localhost:7054",
            "caName": "ca-org1",
            "httpOptions": {
                "verify": false
            }
        },
        "ca.org2.iot.net": {
            "url": "https://localhost:8054",
            "caName": "ca-org2",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF
composer card create -p $CONNECTION_ORG1/toan-network-org1.json -u PeerAdmin1 -c $CONNECTION_ORG1/Admin@org1.iot.net-cert.pem -k $CONNECTION_ORG1/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@toan-network-org1.card
composer card create -p $CONNECTION_ORG2/toan-network-org2.json -u PeerAdmin2 -c $CONNECTION_ORG2/Admin@org2.iot.net-cert.pem -k $CONNECTION_ORG2/*_sk -r PeerAdmin -r ChannelAdmin -f PeerAdmin@toan-network-org2.card

if composer card list -c PeerAdmin@toan-network-org1 > /dev/null; then
    composer card delete -c PeerAdmin@toan-network-org1
fi

if composer card list -c PeerAdmin@toan-network-org2 > /dev/null; then
    composer card delete -c PeerAdmin@toan-network-org2
fi
composer card import -f PeerAdmin@toan-network-org1.card --card PeerAdmin@toan-network-org1
composer card import -f PeerAdmin@toan-network-org2.card --card PeerAdmin@toan-network-org2