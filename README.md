# edgex-checkbox-provider

[![GitHub Latest Dev Tag)](https://img.shields.io/github/v/tag/canonical/edgex-checkbox-provider?include_prereleases&sort=semver&label=latest-dev)](https://github.com/canonical/edgex-checkbox-provider/tags) 
[![GitHub License](https://img.shields.io/github/license/canoical/edgex-checkbox-provider)](https://choosealicense.com/licenses/apache-2.0/) 
[![GitHub Pull Requests](https://img.shields.io/github/issues-pr-raw/canonical/edgex-checkbox-provider)](https://github.com/edgexfoundry/edgex-cli/pulls) 
[![GitHub Contributors](https://img.shields.io/github/contributors/canonical/edgex-checkbox-provider)](https://github.com/edgexfoundry/edgex-cli/contributors) 
[![GitHub Committers](https://img.shields.io/badge/team-committers-green)](https://github.com/orgs/canonical/teams/edgex/members) 
[![GitHub Commit Activity](https://img.shields.io/github/commit-activity/m/edgexfoundry/edgex-cli)](https://github.com/canonical/edgex-checkbox-provider/commits)

## Introduction

This project contains the checkbox tests of the [edgex foundry](https://docs.edgexfoundry.org/) snaps. 
[Checkbox](https://checkbox.readthedocs.io/en/latest/) is a test automation software performed by the Canonical certification team. 
The [upstream repository](https://github.com/canonical/edgex-checkbox-provider) is hosted on Github; 
The tests run via the [Launchpad mirror](https://code.launchpad.net/checkbox-provider-edgex).

When edgexfoundry snap is released to the latest/beta channel, the corresponding checkbox test will be triggered. 

## Hardware

This table shows hardware used for edgexfoundry snap checkbox tests:
| Architecture | amd64              | amd64                          | amd64                  | arm64                         | arm64                       | arm64            | arm64                                     |           arm64           |
| ------------ | ------------------ | ------------------------------ | ---------------------- | ----------------------------- | --------------------------- | ---------------- | ----------------------------------------- | :-----------------------: |
| Model        | Tulip 17 BDW       | Caracalla                      | St. Louis              | RPI4B4G                       | RPI4B8G                     | RPI400           | CM4L                                      |        DragonBoard        |
| Information  | Dell Inspiron 5758 | Dell Edge Gateway 3003 [Media] | Dell Edge Gateway 5000 | armv7l Raspberry Pi 4 Model B | Raspberry  Pi 4 Model B 8GB | Raspberry Pi 400 | Raspberry Pi Compute Module 4 Lite - CM4L | Qualcomm DragonBoard 410c |
| Ubuntu OS    | Core 16/16 LTS     | Core 16                        | Core 16                | 16 LTS                        | 16 LTS                      | 16 LTS           | 16 LTS                                    |          16 LTS           |



## Usage

### Run tests using checkbox CLI
```bash
git clone https://github.com/canonical/edgex-checkbox-provider.git
cd edgex-checkbox-provider/
sudo ./manage.py install
checkbox-cli
```
![image-checkbox-test-plans](./assets/checkbox-test-plans.png)

Press SPACE to select an EdgeX test plan, then choose tests to run on your system:
![image-edgex-test-plan](./assets/edgex-test-plan.png)

### Run tests locally
Remove these snaps to avoid missing edgex-secretstore-token issue, if applicable:
```bash
snap remove --purge <edegx-device-service>
snap remove --purge <edgex-app-service>
```
Get the edgex-checkbox-provider:
```bash
git clone https://github.com/canonical/edgex-checkbox-provider.git
cd edgex-checkbox-provider/data/jakarta
```
Download a specific version snap:
```bash
snap download edgexfoundry <channel>
sudo ./run-all-tests-locally.sh -s <edgexfoundry.snap> -t <single test>
```
Here are some examples:


```bash
# run a single test using locally built snaps
snap download edgexfoundry --channel=2.1/stable
sudo ./run-all-tests-locally.sh -s edgexfoundry_3375.snap -t test-rules-engine.sh
```
```bash
# run all tests using locally built snaps
sudo ./run-all-tests-locally.sh-s edgexfoundry_3375.snap
```
```bash
# run a single test using snap from latest/beta channel
sudo ./run-all-tests-locally.sh -t test-rules-engine.sh
```
```bash
# run all tests using snap from latest/beta channel
sudo ./run-all-tests-locally.sh
```
```bash
# run tests showing output of tests even if passed
sudo ./run-all-tests-locally.sh -t -v
sudo ./run-all-tests-locally.sh -t test-install.sh -v
```
```bash
# get a list of available options
sudo ./run-all-tests-locally.sh -h
```

## Testing coverage
- Test installation of EdgeX snap
- Test security services proxy certs work properly
- Test that all services can be started properly
- Test that installing uses "current" based file paths in config files
- Test that refreshing uses "current" based file paths in config files
- Test that services start after refreshing 
- Test that services start after refreshing to this revision from self
- Test that the system management agent works with the snap
- Test that services are not listening on external network interfaces
- Test that the rules engine works with the snap
- mandatory tests: interface, meminfo, connections ,[etc](https://github.com/canonical/edgex-checkbox-provider/blob/master/units/test-plan.pxu#L113).

## Limitations
- The current tests plan only covers [edgexfoundry snap](https://github.com/edgexfoundry/edgex-go/tree/main/snap), it does not cover [device services snaps](https://github.com/edgexfoundry/edgex-docs/blob/main/docs_src/getting-started/Ch-GettingStartedSnapUsers.md#device-service-snaps) and [app services snap](https://github.com/edgexfoundry/app-service-configurable/tree/main/snap)
- edgex-secretstore-token content interface is not be covered by tests

## License
[Apache-2.0](LICENSE)
