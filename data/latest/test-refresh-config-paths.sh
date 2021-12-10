#!/bin/bash -e

# This test checks if all files in $SNAP_DATA don't reference the previous revision
# after upgrading the snap from 2.1/stable to latest/beta

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the latest release utils
# shellcheck source=/dev/null
source "$SCRIPT_DIR/utils.sh"

DEFAULT_TEST_CHANNEL=${DEFAULT_TEST_CHANNEL:-beta}

snap_remove

# first make sure that the snap installs correctly from the channel
# or use locally cached version of jakarta 
if [ -n "$EDGEX_JAKARTA_SNAP_FILE" ]; then
    snap_install "$EDGEX_JAKARTA_SNAP_FILE"
    echo "snap edgexfoundry is installed from 2.1/stable channel"
else
    snap_install edgexfoundry 2.1/stable
    echo "snap edgexfoundry is installed from 2.1/stable channel"
fi

# get the revision number for this channel
SNAP_REVISION=$(snap run --shell edgexfoundry.consul -c "echo \$SNAP_REVISION")

# wait for services to come online
snap_wait_all_services_online

snap_check_svcs

# now upgrade the snap from stable to latest
if [ -n "$REVISION_TO_TEST" ]; then
    snap_install "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
    echo "snap edgexfoundry upgraded from 2.1/stable to latest/beta channel successfully"
else
    snap_refresh edgexfoundry "$DEFAULT_TEST_CHANNEL"
    echo "snap edgexfoundry upgraded from 2.1/stable to latest/beta channel successfully"
fi

# wait for services to come online
snap_wait_all_services_online

snap_check_svcs

echo "checking for files with previous snap revision $SNAP_REVISION"

# check that all files in $SNAP_DATA don't reference the previous revision
# except for "Binary file consul/data/raft/raft.db"
# ends up putting the path including the old revision number inside
pushd /var/snap/edgexfoundry/current > /dev/null
set +e
notUpgradedFiles=$(grep -R "edgexfoundry/$SNAP_REVISION" | grep -v "raft.db")
     
popd > /dev/null
if [ -n "$notUpgradedFiles" ]; then
    echo "files not upgraded to use \"current\" symlink in config files:"
    echo "$notUpgradedFiles"
    exit 1
else
    echo "no files reference previous snap revision found"
fi
set -e

# remove the snap to run the next test
snap_remove
