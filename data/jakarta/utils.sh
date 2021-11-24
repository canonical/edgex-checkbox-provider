#!/bin/bash -e

if [ "$(id -u)" != "0" ]; then
    echo "script must be run as root"
    exit 1
fi

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the generic utils
# shellcheck source=/dev/null
source "$(dirname "$SCRIPT_DIR")/utils.sh"

snap_check_svcs()
{
    if [ "$1" = "--notfatal" ]; then
        FATAL=0
    else
        FATAL=1
    fi

    # group services by status

    check_enabled_services \
        `#core services` \
        "redis \
        core-data \
        core-command \
        core-metadata \
        `#security services` \
        kong-daemon postgres vault consul 
        `#one-shot security services` \
        security-proxy-setup \
        security-secretstore-setup \
        security-bootstrapper-redis \
        security-consul-bootstrapper "

    check_active_services \
        `#core services` \
        "redis \
        core-data \
        core-command \
        core-metadata \
        `#security services` \
        kong-daemon postgres vault consul"

    check_disabled_services \
        `#app service, kuiper and device-virtual`\
        "app-service-configurable kuiper device-virtual \
        `#support services, system service` \
        support-notifications \
        support-scheduler \
        sys-mgmt-agent"

    check_inactive_services \
        `#app service, kuiper and device-virtual `\
        "app-service-configurable kuiper device-virtual \
        `#one-shot security services` \
        security-proxy-setup \
        security-secretstore-setup \
        security-bootstrapper-redis \
        security-consul-bootstrapper \
        `#support services, system service` \
        support-notifications \
        support-scheduler \
        sys-mgmt-agent"    
}
