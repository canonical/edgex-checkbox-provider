#!/bin/bash -e

# This test validates a smooth upgrade between 2.0/stable channel and latest/beta channel

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the latest release utils
# shellcheck source=/dev/null
source "$SCRIPT_DIR/utils.sh"

snap_remove

# first make sure that the snap installs correctly from the channel
# or use locally cached version of ireland 
if [ -n "$EDGEX_IRELAND_SNAP_FILE" ]; then
    snap_install "$EDGEX_IRELAND_SNAP_FILE"
    echo "snap edgexfoundry is installed from 2.0/stable channel"
else
    snap_install edgexfoundry 2.0/stable
    echo "snap edgexfoundry is installed from 2.0/stable channel"
fi    

# wait for services to come online
snap_wait_all_services_online

snap_check_svcs

# now upgrade the snap from stable to latest
if [ -n "$REVISION_TO_TEST" ]; then
    snap_refresh "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
    echo "snap edgexfoundry is upgraded from 2.0/stable to latest/beta channel"
else
    snap_refresh edgexfoundry latest/beta 
    echo "snap edgexfoundry is upgraded from 2.0/stable to latest/beta channel"
fi

# wait for services to come online
snap_wait_all_services_online

snap_check_svcs

# remove the snap to run the next test
snap_remove
