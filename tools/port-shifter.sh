#!/bin/bash

# PORT SHIFTER for client.toml, app.toml and config.toml files (Wrapper variant)
# Original: https://github.com/zenodeapp/port-shifter
# ZENODE (https://zenode.app)

# Root of repository
ROOT=$(cd "$(dirname "$0")"/.. && pwd)

# Source the _variables.sh file
. "$ROOT/_variables.sh"

# Where the downloaded script has to be saved
SAVE_AS="$ROOT/tools/_port-shifter.sh"

# Repository where the port shifter resides
VERSION=v1.0.1 # Added versioning for non-breaking changes and security measures
EXTERNAL_REPO=https://raw.githubusercontent.com/zenodeapp/port-shifter/$VERSION

# quick-shift.sh (simple variant, $1 is <port_increment_value>, e.g.: 1000)
# See https://github.com/zenodeapp/port-shifter/blob/v1.0.1/quick-shift.sh
wget -O $SAVE_AS $EXTERNAL_REPO/quick-shift.sh
# shift-wizard.sh (more advanced, if you prefer to edit individual ports)
# See: https://github.com/zenodeapp/port-shifter/blob/v1.0.1/shift-wizard.sh
# wget -O $SAVE_AS $EXTERNAL_REPO/shift-wizard.sh

# Execute script and remove it
sh $SAVE_AS "$CONFIG_DIR" $1
rm $SAVE_AS
