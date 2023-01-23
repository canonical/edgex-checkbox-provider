#!/bin/bash -e

rm -rf edgex-snap-testing

git clone https://github.com/canonical/edgex-snap-testing.git
cd edgex-snap-testing
PLATFORM_CHANNEL="latest/beta" FULL_CONFIG_TEST=true go test -failfast -p 1 -timeout 30m -v ./test/suites/edgexfoundry

rm -rf edgex-snap-testing
