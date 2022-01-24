#!/bin/bash -e

###
# This test verifies the correct migration of postgres from v10 to v12

# 1) We need the previous EdgeXFoundry version to have a pre-refresh hook, that creates a kong.sql file.
# As we don't have that at the moment, then a kong.sql file has been manually generated and included in
# the test-files directory.

# for reference, that was done using:

# install Ireland version
#sudo snap remove --purge edgexfoundry
#sudo snap install edgexfoundry --channel=2.0/stable
# create keys
#openssl ecparam -genkey -name prime256v1 -noout -out private.pem
#openssl ec -in private.pem -pubout -out public.pem
## set up Kong user
#PUBLIC_KEY=$(< public.pem)
#sudo snap set edgexfoundry env.security-proxy.user=user01,USER_ID,ES256
#sudo snap set edgexfoundry env.security-proxy.public-key="$PUBLIC_KEY"
# create JWT token for user
#edgexfoundry.secrets-config proxy jwt --algorithm ES256 --private_key private.pem --id USER_ID --expiration=1h > token.jwt
# create kong.sql file
#sudo mkdir /var/snap/edgexfoundry/common/refresh
#sudo chown -R snap_daemon:snap_daemon /var/snap/edgexfoundry/common/refresh
#sudo snap run --shell edgexfoundry.psql
    #export PGPASSWORD=`cat /var/snap/edgexfoundry/current/config/postgres/kongpw`
    #pg_dump -Ukong kong -f$SNAP_COMMON/refresh/kong.sql
    #exit
#cp /var/snap/edgexfoundry/common/refresh/kong.sql ./test-files

# 2) The Kamakura version is Epoch 6, so this test also fails, as we don't have a 6* version yet with the hook.
# Therefore, to run this test, you need to change snapcraft.yaml to epoch:5, rebuild and run this test

###

# get the directory of this script
# snippet from https://stackoverflow.com/a/246128/10102404
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# load the latest release utils
# shellcheck source=/dev/null
source "$SCRIPT_DIR/utils.sh"

mkdir -p "$SCRIPT_DIR/tmp"
TMP_DIR="$SCRIPT_DIR/tmp"


# keys used for Kong user. Generated as per instructions above
PUBLIC_KEY="-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEClcESKY3Nvs3cEDOUsnsiBTTm8Cd
7x76Ggp2Y3Xhs30A7Bgt6SkOm3t/zaIXfGDkpSlCZuFKmBxRVeglMSdZCg==
-----END PUBLIC KEY-----"

PRIVATE_KEY="-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIC8o4g5vJ78IEJryNI29TOYfF1K+uMt6gpUOURkyP4EsoAoGCCqGSM49
AwEHoUQDQgAEClcESKY3Nvs3cEDOUsnsiBTTm8Cd7x76Ggp2Y3Xhs30A7Bgt6SkO
m3t/zaIXfGDkpSlCZuFKmBxRVeglMSdZCg==
-----END EC PRIVATE KEY-----"

# install EdgeXFoundry 2.0
sudo snap remove --purge edgexfoundry
sudo snap install edgexfoundry --channel=2.0/stable

# 2.0 doesn't contain the pre-refresh hook, so create the file that would have been output
sudo mkdir /var/snap/edgexfoundry/common/refresh
sudo cp $SCRIPT_DIR/test-files/kong.sql /var/snap/edgexfoundry/common/refresh
sudo chown -R snap_daemon:snap_daemon /var/snap/edgexfoundry/common/refresh

# install the new version, which will then pick up the kong.sql file
if [ -n "$REVISION_TO_TEST" ]; then
    echo "Installing snap from locally cached version"
    snap_install "$REVISION_TO_TEST" "$REVISION_TO_TEST_CHANNEL" "$REVISION_TO_TEST_CONFINEMENT"
else
    echo "Installing snap from channel"
    snap_install edgexfoundry "$DEFAULT_TEST_CHANNEL" 
fi
 
# confirm that we can log in using the public key 
echo "$PRIVATE_KEY" > "$TMP_DIR/private.pem"
TOKEN=$(edgexfoundry.secrets-config proxy jwt --algorithm ES256 --private_key $TMP_DIR/private.pem --id USER_ID --expiration=1h)

# note: we need to use "edgexfoundry.curl", not "curl" to correctly support TLS 1.2

echo "Verifying self-signed TLS certificate"
code=$(edgexfoundry.curl --insecure --show-error --silent --include \
    --output /dev/null --write-out "%{http_code}" \
    -X GET 'https://localhost:8443/core-data/api/v2/ping?' \
    -H "Authorization: Bearer $TOKEN") 
if [[ $code != 200 ]]; then
    >&2 echo "self-signed Kong TLS verification test failed with $code"
    snap_remove
    exit 1
else
    echo "Self-signed TLS verification test succeeded"
fi
 
rm -rf $TMP_DIR 