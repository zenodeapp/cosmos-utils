#!/bin/bash

CHAIN_ID=tgenesis_54-1
BINARY_NAME=tgenesisd
NODE_DIR_NAME=.tgenesis
NODE_DIR=$HOME/$NODE_DIR_NAME
CONFIG_DIR=$NODE_DIR/config
DATA_DIR=$NODE_DIR/data

# /fetch module variables.
# Adviced is to create a repo containing a genesis.json, seeds.txt, peers.txt and rpc_servers.txt file.
# See: https://github.com/zenodeapp/genesis-parameters/tree/main/genesis_29-2 for an example.
FETCH_URL=https://raw.githubusercontent.com/zenodeapp/genesis-parameters/main/$CHAIN_ID
SEEDS_URL=$FETCH_URL/seeds.txt
PEERS_URL=$FETCH_URL/peers.txt
STATE_URL=$FETCH_URL/genesis.json
RPC_SERVERS_URL=$FETCH_URL/rpc_servers.txt

# /info module variables.
IP_INFO_PROVIDER=ipinfo.io/ip

# /service module variables.
SERVICE_DIR=~/genesis-cronos/services # Where the service file is located, $REPO_ROOT is not defined in this example.
SERVICE_FILE=$BINARY_NAME.service