# edgex-checkbox-provider

This project contains the [Checkbox](https://checkbox.readthedocs.io/en/latest/) tests of the [Edgex Foundry](https://docs.edgexfoundry.org/) snaps.

Upstream: https://github.com/canonical/edgex-checkbox-provider  
Mirror: https://code.launchpad.net/checkbox-provider-edgex  
The mirror and upstream are synced automatically every 5 hours. The import may be triggered manually.

When a snap is released to a `$TRACK/beta` channel, the corresponding checkbox tests are triggered on [Ubuntu certified hardware](https://ubuntu.com/certified).

The [checkbox-edgexfoundry](https://snapcraft.io/checkbox-edgexfoundry) allows the execution of tests on different platforms.
Note that this doesn't provide full isolation as we need to install it in [developer mode](https://snapcraft.io/docs/install-modes#heading--developer) to have the necessary system access.

## Usage
> **EdgeX 2.3 and older**  
> For testing EdgeX 2.3 (Levski), 2.1 (Jakarta/LTS), and older, refer to the [edgex-v2](https://github.com/canonical/edgex-checkbox-provider/tree/edgex-v2) branch.

This snap is built on
[launchpad](https://launchpad.net/~ce-certification-qa/+snap/checkbox-edgexfoundry-edge)
from the mirror (see above) and published as
[checkbox-edgexfoundry](https://snapcraft.io/checkbox-edgexfoundry).


Install the snap:
```bash
sudo snap install checkbox-edgexfoundry --devmode --edge
```

Run:
```bash
sudo DEFAULT_TEST_CHANNEL="latest/beta" checkbox-edgexfoundry.latest
```

### Run using Checkbox CLI
```bash
checkbox-edgexfoundry.checkbox-cli
```

Then, scroll down and press SPACE to select the desired test plan:
```bash
Select test plan
┌─────────────────────────────────────────────────┐
│    ( ) Dock Hot Plug tests                      │
│    ( ) EdgeX Fuji                               │
│    ( ) EdgeX Geneva                             │
│    ( ) EdgeX Hanoi                              │
│    ( ) EdgeX Ireland                            │
│    ( ) EdgeX Jakarta                            │
│    (X) EdgeX Latest                             │
│    ( ) Firewire tests                           │
└─────────────────────────────────────────────────┘
Press <Enter> to continue                (H) Help
```

### Run on Ubuntu Core 16

1. Start a `core` instance with Multipass:
```bash
multipass launch core --name=uc16
```

2. If built locally, transfer the snap to the VM instance:
```bash
multipass transfer checkbox-edgexfoundry_2.0_amd64.snap uc16:
```

3. Open a shell and run the tests as usual:
```bash
multipass shell uc16
```
## Development
The snap can be build locally using the `snapcraft` command.

Install:
```bash
sudo snap install --devmode --dangerous ./checkbox-edgexfoundry_2.0_amd64.snap
```

If installed from scratch, manually connect the interfaces:
```bash
# sudo snap install checkbox20 # installed automatically as it is the default provider for a few plugs
sudo snap connect checkbox-edgexfoundry:checkbox-runtime checkbox20:checkbox-runtime
sudo snap connect checkbox-edgexfoundry:provider-resource checkbox20:provider-resource
sudo snap connect checkbox-edgexfoundry:provider-checkbox checkbox20:provider-checkbox
```

Then, run the tests as usual.

### Modify snapped tests
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
The latest tests are written in Go, available [here](https://github.com/canonical/edgex-snap-testing/tree/main/test/suites).

To check the used testing suites, refer to [units/latest.pxu](units/latest.pxu).

## Limitations
- The current tests plan only covers the [edgexfoundry](https://snapcraft.io/edgexfoundry) snap. It does not cover any of the device or app service snaps.

