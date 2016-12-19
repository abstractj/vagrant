#!/bin/sh

set -e

# Change to your own needs
REALM=TEST.LOCAL
IPA=keycloak.$DOMAIN
PASSWORD=password

#hostnamectl set-hostname $IPA
ipa-server-install --realm=$REALM --setup-dns --no-forwarders --ds-password=$PASSWORD --admin-password=$PASSWORD -U
