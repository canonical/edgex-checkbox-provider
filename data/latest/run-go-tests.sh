#!/bin/bash -e

# $1 - edgex-snap-testing test suite

if [ -f edgex-snap-testing ]; then
    rm -rf edgex-snap-testing
fi

git clone --depth 1 --branch v3 https://github.com/canonical/edgex-snap-testing.git
cd edgex-snap-testing

export PLATFORM_CHANNEL=$DEFAULT_TEST_CHANNEL

go test -failfast -p 1 -timeout 30m -v ./test/suites/$1
EXIT_CODE=$?
LOG=./edgex-snap-testing/test/suites/edgexfoundry.log
if [ $EXIT_CODE -ne 0 ]; then
    echo "Begin of Errors Log"
    cat $LOG | grep --ignore-case "error"
    echo "End of Errors Log"
fi


