#!/bin/bash

# Copyright 2016 Jan Pazdziora
#
# Licensed under the Apache License, Version 2.0 (the "License").

# If the machine is not yet IPA-enrolled, fetch its OTP from the IPA
# server and IPA-enroll the machine. In container with Apache HTTP
# server, also get keytab for the HTTP/ service and SSL certificate.

set -e

# Change to your own needs
DOMAIN=test.local
IPA=keycloak.$DOMAIN
PASSWORD=password

exec >> /proc/1/fd/1 2>> /proc/1/fd/2

if [ -f /etc/ipa/default.conf ] ; then
	echo "$HOSTNAME is already IPA-enrolled."
	exit
fi

(
set -x
ipa-client-install -U -w $PASSWORD --domain=$DOMAIN -p admin --force-join
)

# Provisioning of testing users

echo $PASSWORD | kinit admin

if ipa user-find emily && ipa user-find david; then
  echo "provision.sh: Example users already exists. Skipping it...";
else
  ipa user-add emily --first=Emily --last=Jones --email=emily@jones.com --phone=783.812.0168 --street="5129 Russell Bridge Apt. 242" --city="New Christineburgh" --state="IN" --postalcode=60759
  echo emily123 | ipa user-mod emily --password

  ipa user-add david --first=David --last=Baker --email=david@baker.com --phone=1-655-139-6802 --street="6440 Baker Corners" --city="Raymondfurt" --state="ID" --postalcode=13959
  echo david123 | ipa user-mod david --password
  echo "provision.sh: Example users added to freeipa";
fi

if ipa group-find testgroup --users=emily; then
  echo "provision.sh: Example user already added to the group. Skipping it...";
else
  ipa group-add testgroup
  ipa group-add-member testgroup --users=emily
  echo "provision.sh: User added to the example's group";
fi


# Setup for SSSD
SSSD_FILE="/etc/sssd/sssd.conf"

if grep -q 'ldap_user_extra_attrs\|allowed_uids\|user_attributes' $SSSD_FILE
then
  systemctl start sssd
  exit
fi

if [ -f "$SSSD_FILE" ];
then
  sed -i '/ldap_tls_cacert/a ldap_user_extra_attrs = mail:mail, sn:sn, givenname:givenname, telephoneNumber:telephoneNumber' $SSSD_FILE
  sed -i 's/nss, pam/nss, pam, ifp/' $SSSD_FILE
  sed -i '/\[ifp\]/a allowed_uids = root\nuser_attributes = +mail, +telephoneNumber, +givenname, +sn' $SSSD_FILE
  # Restart services after changes
  systemctl restart sssd
else
  echo "Please make sure you have $SSSD_FILE into your system! Aborting."
  exit 1
fi
