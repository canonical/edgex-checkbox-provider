#!/bin/bash -e

# This test checks if the pre-refresh hook and post-refresh hook work 

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the latest release utils
# shellcheck source=/dev/null
source "$SCRIPT_DIR/utils.sh"

DEFAULT_TEST_CHANNEL=${DEFAULT_TEST_CHANNEL:-beta}

# remove the snap if it's already installed
snap_remove

# install the snap version we are testing
if [ -n "$REVISION_TO_TEST" ]; then
    snap_install "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
else
    snap_install edgexfoundry "$DEFAULT_TEST_CHANNEL" 
fi

# wait for services to come online
snap_wait_all_services_online

snap_check_svcs

# now install the same snap version we are testing to test the pre-refresh
# and post-refresh logic in this revision
if [ -n "$REVISION_TO_TEST" ]; then
    snap_install "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
else
    # if we aren't running locally, then we need to download the revision and
    # install it locally as if it was a different revision
    snap_download_output=$(snap download edgexfoundry --channel="$DEFAULT_TEST_CHANNEL")
    THIS_REVISION_LOCALLY="$(pwd)/$(echo "$snap_download_output" | grep -Po 'edgexfoundry_[0-9]+\.snap')"
    snap_install "$THIS_REVISION_LOCALLY" "" "--devmode"
fi

# wait for services to come online
snap_wait_all_services_online

snap_check_svcs

# check pre-refresh hook
# ensure the release config item is set to jakarta
snapRelease=$(snap get edgexfoundry release)
if [ "$snapRelease" != "jakarta" ]; then
    echo "missing or invalid config item for snap release: \"$snapRelease\""
    snap_remove
    exit 1
fi

# check post-refresh hook
# if kong-admin-jwt has been removed in the context of the new snap
# revision, and prior to services being started
KONG_ADMIN_JWT="/var/snap/edgexfoundry/current/secrets/security-proxy-setup/kong-admin-jwt"
if [ ! -f "$KONG_ADMIN_JWT" ]; then
    echo "Cannot force remove kong-admin-jwt after snap refresh"
    snap_remove
    exit 1
fi
snap_remove

