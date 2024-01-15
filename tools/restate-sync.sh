#!/bin/bash

# RESTATE SYNC for recalibrating to a more recent height (Wrapper variant)
# Original: https://github.com/zenodeapp/restate-sync
# ZENODE (https://zenode.app)

# $1 is [height_interval] (default: 2000)
# $2 is [rpc_server_1] (default: the first rpc configured in rpc_servers)
# $3 is [rpc_server_2] (default: [rpc_server_1])

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Source the _variables.sh file
. "$ROOT/_variables.sh"

# Where the restate-sync.sh file has to be saved.
SAVE_AS="$ROOT/tools/_restate-sync.sh"

# Repository where the port shifter resides
VERSION=v1.0.0 # Added versioning for non-breaking changes and security measures
EXTERNAL_REPO=https://raw.githubusercontent.com/zenodeapp/restate-sync/$VERSION

# restate-sync.sh
# See https://github.com/zenodeapp/restate-sync/blob/v1.0.0/restate-sync.sh
wget -O $SAVE_AS $EXTERNAL_REPO/restate-sync.sh
if sh $SAVE_AS "$BINARY_NAME" "$NODE_DIR_NAME" "$1" "$2" "$3"; then
    rm $SAVE_AS
else
    rm $SAVE_AS
    exit 1
fi
