# edgex-checkbox-provider

This project contains the [Checkbox](https://checkbox.readthedocs.io/en/latest/) tests of the [Edgex Foundry](https://docs.edgexfoundry.org/) snaps.

The upstream repository is hosted on Github: https://github.com/canonical/edgex-checkbox-provider

A mirror is available on Launchpad: https://code.launchpad.net/checkbox-provider-edgex  
The mirror and upstream are synced automatically every 5 hours. The import may be triggered manually.

When a snap is released to a `$TRACK/beta` channel, the corresponding checkbox tests are triggered on [Ubuntu certified hardware](https://ubuntu.com/certified). The tests reference the mirror that is available on Launchpad.

## Installation

This is the recommended method as it runs all the tests in isolation.

This snap is built on
[launchpad](https://launchpad.net/~ce-certification-qa/+snap/checkbox-edgexfoundry-edge)
from the mirror (see above) and published as
[checkbox-edgexfoundry](https://snapcraft.io/checkbox-edgexfoundry).

The checkbox-edgexfoundry snap should be installed in [developer mode](https://snapcraft.io/docs/install-modes#heading--developer) to have full access. 

To install:
```bash
sudo snap install checkbox-edgexfoundry --devmode --edge
```

## Usage

1. Set `<channel>` to snap channel, and `<release name>` to the EdgeX release name:
```bash
sudo DEFAULT_TEST_CHANNEL="<channel>" checkbox-edgexfoundry.<release name>
```

For example:
```bash
sudo DEFAULT_TEST_CHANNEL="latest/beta" checkbox-edgexfoundry.latest
```

Alternatively, run tests using checkbox CLI:

```bash
checkbox-edgexfoundry.checkbox-cli
```

2. Scroll down and press SPACE to select the desired test plan:
```bash
Select test plan
┌─────────────────────────────────────────────────┐
│    ( ) Dock Hot Plug tests                      │
│    ( ) EdgeX Fuji                               │
│    ( ) EdgeX Geneva                             │
│    ( ) EdgeX Hanoi                              │
│    ( ) EdgeX Ireland                            │
│    ( ) EdgeX Jakarta                            │
│    (X) EdgeX latest                             │
│    ( ) Firewire tests                           │
└─────────────────────────────────────────────────┘
Press <Enter> to continue                (H) Help
```

## Development

### Build 
To build checkbox-edgexfoundry snap from source, run the command:
```bash
snapcraft -v
```

### Run
There are four ways to run tests:
#### Run local built checkbox-edgexfoundry snap in virtual machine
This is the recommended method as it runs all the tests in isolation.

To run the checkbox-edgexfoundry snap in a virtual machine, follow these steps:

1. Install and start a virtual machine with Multipass:
```bash
snap install multipass
multipass launch core --name=uc16
multipass shell uc16
```
2. Transfer the snap from outside the virtual machine to the virtual machine instance:
```bash
multipass transfer checkbox-edgexfoundry_2.0_amd64.snap uc16:
```
3. Install and connect the checkbox-edgexfoundry snap:
```bash
sudo snap install --devmode --dangerous ./checkbox-edgexfoundry_2.0_amd64.snap
```
4. To run the Checkbox test on Ubuntu Core, the connection of content interface snap providers is required. 
First, install checkbox20 and then manually connect the interfaces using the following commands:
```bash
sudo snap install checkbox20
sudo snap connect checkbox-edgexfoundry:checkbox-runtime checkbox20:checkbox-runtime
sudo snap connect checkbox-edgexfoundry:provider-resource checkbox20:provider-resource
sudo snap connect checkbox-edgexfoundry:provider-checkbox checkbox20:provider-checkbox
```
#### Run local built checkbox-edgexfoundry snap natively
1. Install checkbox-edgexfoundry snap:
```bash
sudo snap install --devmode --dangerous ./checkbox-edgexfoundry_2.0_amd64.snap
```
2. Install checkbox20 and then manually connect the interfaces using the following commands:
```bash
sudo snap install checkbox20
sudo snap connect checkbox-edgexfoundry:checkbox-runtime checkbox20:checkbox-runtime
sudo snap connect checkbox-edgexfoundry:provider-resource checkbox20:provider-resource
sudo snap connect checkbox-edgexfoundry:provider-checkbox checkbox20:provider-checkbox
```
#### Run test using Checkbox CLI from source:
1. Install dependency
```bash
sudo pip install plainbox
```
2. Install and run Checkbox CLI
```bash
cd edgex-checkbox-provider/
sudo ./manage.py install
checkbox-cli
```
#### Run test scripts directly
Enter the desired test directory, then get a list of available options: 
```bash
sudo ./run-all-tests-locally.sh -h
```

For example, to run a single test with a local snap:

```bash
sudo ./run-all-tests-locally.sh -s edgexfoundry.snap -t test-rules-engine.sh
```

To run tests against a snap from a specific channel:
```bash
sudo DEFAULT_TEST_CHANNEL="<channel>" ./run-all-tests-locally.sh
```

### Modify snapped tests
The checkbox-edgexfoundry snap packages all the test files inside during the build.
To modify those test files without rebuilding the snap, follow these steps:
1. Get the checkbox-edgexfoundry snap and unsquash it:

```bash
snap download checkbox-edgexfoundry --edge
unsquashfs checkbox-edgexfoundry_99.snap 
```

2. Update the test you are working on in `./squashfs-root/providers/checkbox-provider-edgex/data/`.

3. Optionally, to save time, modify latest.pxu to remove all tests other than the one you are testing.

4. Run the tests with:

```bash
mksquashfs ./squashfs-root checkbox-edgexfoundry.snap  -noappend -comp xz -all-root -no-xattrs -no-fragments
sudo snap install ./checkbox-edgexfoundry.snap --devmode
sudo snap connect checkbox-edgexfoundry:checkbox-runtime checkbox20:checkbox-runtime
sudo snap connect checkbox-edgexfoundry:provider-resource checkbox20:provider-resource
sudo snap connect checkbox-edgexfoundry:provider-checkbox checkbox20:provider-checkbox
sudo DEFAULT_TEST_CHANNEL="latest/beta" checkbox-edgexfoundry.latest
```

## Testing coverage
- Test the installation of edgexfoundry snap
- Test security services proxy certs work properly
- Test that all services can be started properly
- Test that config paths don't include previous snap revision after installation
- Test that config paths don't include previous snap revision after refresh
- Test that services start after refreshing
- Test that services start after refreshing to the same revision
- Test that the system management agent works with the snap
- Test that services are not listening on external network interfaces
- Test that the rules engine works with the snap
- Test that snap configure hook settings are supported by the edgexfoundry snap
- Test that edgex-device-virtual creates devices and produces readings
- Mandatory tests: see [units/test-plan.pxu#L113](./units/test-plan.pxu#L113)

## Limitations
- The current tests plan only covers the [edgexfoundry](https://snapcraft.io/edgexfoundry) snap. It does not cover any of the device or app service snaps.

