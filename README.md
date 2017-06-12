# Keymaster

#### Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with keymaster](#setup)
    * [What keymaster affects](#what-keymaster-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with keymaster](#beginning-with-keymaster)
4. [Usage - Configuration options and additional functionality](#usage)
5. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Limitations - OS compatibility, etc.](#limitations)
6. [Development - Guide for contributing to the module](#development)

## Overview

The Keymaster module is intended to manage the deployment and redeployment of keys, certificate, and other security tokens across Puppet nodes, services, applications, and users.

## Module Description

Keymaster will generate self-signed keys and deploy them, or can deploy keys that have been pre-generated and seeded into its keystore. Keymaster can also generate x509 certificates, either self-signed or signed via the Comodo Cert Manager API.

Keymaster manages SSH keys and certificates for users and nodes such that they are available via a Puppet manifest and can be used and deployed through the Puppet infrastructure without requiring the content of a key or certificate to be stored in a Puppet manifest or Hiera data store.

This module does not install the ssh client, sshd service, or the OpenSSH packages. The [https://forge.puppetlabs.com/saz/ssh](saz-ssh) module is recommended for managing the ssh client and service.

## Setup

### What keymaster affects

* Sets up and secures the keystore (`/etc/puppetlabs/keymaster`) to store the files used by the other resources defined in this module.
* Installs the required ruby gems to call the Comodo Cert Manager API.
* Installs and configures the cert-manager script.

### Setup Requirements

If your setup requires a specific ruby path, be sure to specify that like when declaring the keymaster class.

```puppet
class { 'keymaster':
  ruby_path => '/your/path',
}
```

### Beginning with keymaster

The very basic steps needed for a user to get the module up and running are:

```puppet
include keymaster
```

## Reference

### keymaster

The `keymaster` class sets up and secures the keystore (`/etc/puppetlabs/keymaster`) to store the files used by the other resources defined in this module, installs the required ruby gems to call the Comodo Cert Manager API, and installs and configures the cert-manager script.

#### Parameters

##### `user`

Name of user for key management. Defaults to `'puppet'`.

##### `group`

Name of group for key management. Defaults to `'puppet'`.

##### `ruby_path`

Path to to use for ruby execs. Defaults to `'/usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin'`.

##### `keystore_base`

Path to keystore base directory. Defaults to `'/etc/puppetlabs/keymaster'`.

##### `keystore_ssh`

Name of directory for ssh key storage. Defaults to `'ssh'`.

##### `keystore_host_key`

Name of directory for host_key storage. Defaults to `'host_key'`.

##### `keystore_x509`

Name of directory for x509 storage. Defaults to `'x509'`.

##### `api_user`

Username for InCommon cert manager API. Optional.

##### `api_pass`

Password for InCommon cert manager API. Optional.

##### `api_org`

Organization for InCommon cert manager API. Optional.

##### `api_key`

Secret key for InCommon cert manager API. Optional.

### keymaster::install

Private class that installs the ruby script and required ruby gems for the cert manager API.

### keymaster::config

Private class that configures the cert manager API script.

### keymaster::params

Private class that sets variables according to platform.

### keymaster::ssh_key

Manages the creation, generation, and deletion of SSH key pairs on the keymaster.

#### Parameters

##### `ensure`

Whether the key should be present. Defaults to `'present'`.

##### `keytype`

Key type (rsa or dsa) to create. Defaults to `'rsa'`.

##### `length`

Key length to ensure. Defaults to `'4096'`.

##### `prefix`

String prefix for the directory in the key store. Optional.

##### `maxdays`

Maximum number of days for the key to exist before regeneration. Optional.

##### `mindate`

Minimum allowed date (e.g., '2017-05-30') for the key. Keys created before this date will be regenerated. Optional.

##### `force`

Force key regeneration. Defaults to `false`.

### keymaster::host_key

Manages the creation, generation, and deletion of host keys on the keymaster.

#### Parameters

##### `ensure`

Whether the key should be present. Defaults to `'present'`.

##### `keytype`

Key type (rsa or dsa) to create. Defaults to `'rsa'`.

##### `length`

Key length to ensure. Defaults to `'4096'`.

##### `prefix`

String prefix for the directory in the key store. Optional.

##### `maxdays`

Maximum number of days for the key to exist before regeneration. Optional.

##### `mindate`

Minimum allowed date (e.g., '2017-05-30') for the key. Keys created before this date will be regenerated. Optional.

##### `force`

Force key regeneration. Defaults to `false`.

### keymaster::x509

Manages the creation, generation, and deletion of x509 certificates on the keymaster.

#### Parameters

##### `common_name`

Common name of the certificate. Required.

##### `ensure`

Whether the cert should be present. Defaults to `'present'`.

##### `country`

Country code in ISO-3166 format. Optional.

##### `organization`

Name of organization for cert. Optional.

##### `state`

State for cert. Optional.

##### `locality`

Locality for cert. Optional.

##### `aliases`

Any additional aliases to include as subject alt names. Optional.

##### `email`

Email address for cert. Optional.

##### `days`

Cert valid duration in days, if self signed. Defaults to `'365'`.

##### `term`

Cert valid duration in years, if not self signed. Defaults to `'3'`.

##### `length`

RSA key size. Defaults to `'4096'`.

##### `self_signed`

Should this be a self-signed certificate. Defaults to `false`.

### keymaster::deploy::ssh_key_pair

Deploys a key pair defined by the keymaster into a user's account on a node.

#### Parameters

##### `user`

User account to install the keys. Required.

##### `filename`

Key filename. Required.

##### `ensure`

Whether the keys should be present. Defaults to `'present'`.

### keymaster::deploy::ssh_authorized_key

Installs a public key into a server user's authorized_keys file.

#### Parameters

##### `user`

User account to install the key. Required.

##### `ensure`

Whether the key should be present. Defaults to `'present'`.

##### `options`

Any additional options passed to the ssh_authorized_key resource. Optional.

### keymaster::deploy::ssh_known_host

Installs a known host key into either a server user's known_hosts file or a specified path.

#### Parameters

##### `user`

User account to install the key. Required.

##### `ensure`

Whether the key should be present. Defaults to `'present'`.

##### `path`

A specific path to the desired known_hosts file. Optional.

##### `aliases`

Any aliases the host might have. Optional.

### keymaster::deploy::x509_key

Deploys an x509 key defined by the keymaster to a file resource on a node.

#### Parameters

##### `ensure`

Whether the key should be present. Defaults to `'present'`.

##### `path`

Absolute path for the key file. Optional.

##### `owner`

File owner for the key file. Optional.

##### `group`

File group for the key file. Optional.

### keymaster::deploy::x509_cert

Deploys an x509 certificate defined by the keymaster to a file resource on a node.

#### Parameters

##### `ensure`

Whether the cert should be present. Defaults to `'present'`.

##### `type`

Format for the cert file. Defaults to `'pem'`.

##### `path`

Absolute path for the cert file. Optional.

##### `owner`

File owner for the cert file. Optional.

##### `group`

File group for the cert file. Optional.

### keymaster::deploy::x509_cert::der

Converts a deployed x509 PEM certificate to a DER certificate on a node.

#### Parameters

##### `ensure`

Whether the cert should be present. Defaults to `'present'`.

##### `type`

Format for the cert file. Defaults to `'crt'`.

##### `path`

Absolute path for the cert file. Optional.

##### `owner`

File owner for the cert file. Optional.

##### `group`

File group for the cert file. Optional.

### keymaster::deploy::x509_cert::p12

Converts a deployed x509 PEM certificate to a PKCS12 certificate on a node.

#### Parameters

##### `ensure`

Whether the cert should be present. Defaults to `'present'`.

##### `type`

Format for the cert file. Defaults to `'p12'`.

##### `path`

Absolute path for the cert file. Optional.

##### `owner`

File owner for the cert file. Optional.

##### `group`

File group for the cert file. Optional.

##### `pass`

Pass phrase for the cert file. Optional.

##### `key`

Should the p12 cert include the key. Defaults to `true`.

## Limitations

Keymaster currently supports RedHat, and Ruby >= 2.0.
