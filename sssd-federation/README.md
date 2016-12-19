# Vagrant box for RHEL 7.2

This box already contains RHEL IdM client and server, plus the dependencies necessary to run Keycloak SSSD federation provider.

If you would like to install more packages or update this box. Please, following the instructions [here to obtain a RHEL subscription](https://access.redhat.com/solutions/253273).

## Getting started

```
$ vagrant up
```

This will bring up RHEL IdM server and automatically enroll the client machine. If you would like to run the integration tests, please change the vagrant file for your own needs.
