#!/bin/bash -e

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the latest release utils
# shellcheck source=/dev/null
source "$SCRIPT_DIR/utils.sh"

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")

snap_remove

# now install the snap version we are testing and check again
if [ -n "$REVISION_TO_TEST" ]; then
    snap_install "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
else
    snap_install edgexfoundry "$DEFAULT_TEST_CHANNEL"  
fi

# wait for services to come online
snap_wait_all_services_online

# enable sys-mgmt-agent, as it's disabled by default
snap set edgexfoundry sys-mgmt-agent=on
snap_wait_port_status 58890 open

# make sure that core-data is running
if [ -n "$(snap services edgexfoundry.core-data | grep edgexfoundry.core-data | grep inactive)" ]; then
    print_error_logs
    echo "core-data is not running"
    snap_remove
    exit 1
fi

# issue a stop command to the SMA for core-data
edgexfoundry.curl \
    --fail \
    --header "Content-Type: application/json" \
    --request POST \
    --data '[{"apiVersion": "v2", "serviceName": "core-data", "action": "stop"}]' \
    localhost:58890/api/v2/system/operation

# check that core-data is no longer running
if [ -z "$(snap services edgexfoundry.core-data | grep edgexfoundry.core-data | grep inactive)" ]; then
    print_error_logs
    echo "SMA failed to stop core-data"
    snap_remove
    exit 1
fi

# issue a start command to the SMA for core-data
edgexfoundry.curl \
    --fail \
    --header "Content-Type: application/json" \
    --request POST \
    --data '[{"apiVersion": "v2", "serviceName": "core-data", "action": "start"}]' \
    localhost:58890/api/v2/system/operation

# check that core-data is now running
if [ -n "$(snap services edgexfoundry.core-data | grep edgexfoundry.core-data | grep inactive)" ]; then
    print_error_logs
    echo "SMA failed to start core-data"
    snap_remove
    exit 1
fi

# issue a bogus start command to the SMA to check that it returns an error message
set +e
status_code=$(edgexfoundry.curl \
    --fail \
    --header "Content-Type: application/json" \
    --request POST \
    --data '[{"apiVersion": "v2", "serviceName": "NOT-A-REAL-SERVICE", "action": "start"}]' \
    localhost:58890/api/v2/system/operation | edgexfoundry.jq '.[0].statusCode')

if [ "$status_code" != "500" ]; then
    print_error_logs
    echo "SMA erronously reports starting a non-existent service"
    snap_remove
    exit 1
fi
set -e

snap_remove

