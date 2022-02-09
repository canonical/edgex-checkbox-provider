#!/bin/bash -e

# This test checks if all files in $SNAP_DATA don't reference the previous revision
# after upgrading the snap from 2.0/stable to latest/beta

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the latest release utils
# shellcheck source=/dev/null
source "$SCRIPT_DIR/utils.sh"

START_TIME=$(date +"%Y-%m-%d %H:%M:%S")
DEFAULT_TEST_CHANNEL=${DEFAULT_TEST_CHANNEL:-beta}
EDGEX_PREV_STABLE_CHANNEL="2.0/stable"

snap_remove

if [ -n "$EDGEX_PREV_STABLE_SNAP_FILE" ]; then
    echo "Installing snap from locally cached version"
    snap_install "$EDGEX_PREV_STABLE_SNAP_FILE"
else
    echo "Installing snap from channel"
    snap_install edgexfoundry $EDGEX_PREV_STABLE_CHANNEL
fi

ORIGINAL_VERSION=$(list_snap edgexfoundry)
echo "Installed $ORIGINAL_VERSION"

SNAP_REVISION=$(snap run --shell edgexfoundry.consul -c "echo \$SNAP_REVISION")
echo "Getting the revision number for this channel: $SNAP_REVISION"

# wait for services to come online
snap_wait_all_services_online

# now upgrade the snap from stable to latest
if [ -n "$REVISION_TO_TEST" ]; then
    snap_install "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
else
    snap_refresh edgexfoundry "$DEFAULT_TEST_CHANNEL"
fi
UPGRADED_VERSION=$(list_snap edgexfoundry)

# wait for services to come online
snap_wait_all_services_online

echo -e "Successfully upgraded:\n\tfrom: $ORIGINAL_VERSION\n\tto:   $UPGRADED_VERSION"

echo "Checking for files with previous snap revision $SNAP_REVISION"

# check that all files in $SNAP_DATA don't reference the previous revision
# except for "Binary file consul/data/raft/raft.db"
# ends up putting the path including the old revision number inside
pushd /var/snap/edgexfoundry/current > /dev/null
set +e
notUpgradedFiles=$(grep -R "edgexfoundry/$SNAP_REVISION" | grep -v "raft.db")
     
popd > /dev/null
if [ -n "$notUpgradedFiles" ]; then
    print_error_logs
    echo "Files not upgraded to use \"current\" symlink in config files:"
    echo "$notUpgradedFiles"
    exit 1
else
    echo "All config file use the current revision path."
fi
set -e

echo "All done. Cleaning up"
# remove the snap to run the next test
snap_remove

