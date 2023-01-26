#!/bin/bash

# This scripts runs the EdgeX Snap tests maintained in
# https://github.com/canonical/edgex-snap-testing

# Arguments:
SUITE=$1 # name of the Go testing package

# Map input variables to those expected by the Go tests
export PLATFORM_CHANNEL=$DEFAULT_TEST_CHANNEL
export SERVICE_CHANNEL=$DEFAULT_TEST_CHANNEL

rm -rf edgex-snap-testing

git clone --config advice.detachedHead=false --depth 1 --branch v3 \
    https://github.com/canonical/edgex-snap-testing.git
cd edgex-snap-testing

echo "Running Go snap tests for $SUITE:"
go test -p 1 -timeout 30m -v ./test/suites/$SUITE
EXIT_CODE=$?
LOG=./test/suites/$SUITE/edgexfoundry.log
if [ $EXIT_CODE -ne 0 ]; then
    echo "========== edgexfoundry snap error logs =========="
    cat $LOG | grep --ignore-case "error"
    echo "=================================================="
fi
