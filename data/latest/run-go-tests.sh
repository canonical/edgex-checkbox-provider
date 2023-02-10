#!/bin/bash -e

# This scripts runs the EdgeX Snap tests maintained in
# https://github.com/canonical/edgex-snap-testing

# Arguments:
SUITE=$1 # name of the Go testing package

# Map input variables to those expected by the Go tests
export PLATFORM_CHANNEL=$DEFAULT_TEST_CHANNEL
export SERVICE_CHANNEL=$DEFAULT_TEST_CHANNEL

# Setup the environment
export GIT_EXEC_PATH=$SNAP/usr/lib/git-core
export GIT_TEMPLATE_DIR=$SNAP/usr/share/git-core/templates
export GIT_CONFIG_NOSYSTEM=1
export PATH=$PATH:$SNAP/usr/lib/go-1.18/bin
export CGO_ENABLED=0

rm -rf tmp

git clone --config advice.detachedHead=false --depth 1 --branch v3 \
    https://github.com/canonical/edgex-snap-testing.git tmp/edgex-snap-testing
cd tmp/edgex-snap-testing

print_logs() {
    EXIT_CODE=$?
    LOG=./test/suites/$SUITE/edgexfoundry.log
    if [ $EXIT_CODE -ne 0 ]; then
        echo "========== edgexfoundry snap error logs =========="
        cat $LOG | grep --ignore-case "error"
        echo "=================================================="
    fi
    exit $EXIT_CODE
}
trap print_logs EXIT

# TODO:
sed -i '/TestTLSCert/a t.Skip("https://github.com/canonical/edgex-checkbox-provider/issues/52")' ./test/suites/edgexfoundry/proxy_test.go
sed -i '/TestAddProxyUser/a t.Skip("https://github.com/canonical/edgex-checkbox-provider/issues/55")' ./test/suites/edgexfoundry/proxy_test.go

echo "Running Go snap tests for $SUITE:"
go test -p 1 -timeout 30m -v ./test/suites/$SUITE
