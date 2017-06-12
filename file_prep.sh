#!/usr/bin/env bash

mkdir -p /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org
mkdir -p /etc/puppetlabs/keymaster/host_key/test.example.org
mkdir -p /etc/puppetlabs/keymaster/x509/test.example.org
echo '-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----' > /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key
echo 'ssh-rsa THISISAFAKERSAHASH foo@baa' > /etc/puppetlabs/keymaster/ssh/tester_at_test.example.org/key.pub
echo '-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----' > /etc/puppetlabs/keymaster/host_key/test.example.org/key
echo 'ssh-rsa THISISAFAKERSAHASH foo@baa' > /etc/puppetlabs/keymaster/host_key/test.example.org/key.pub
echo '-----BEGIN RSA PRIVATE KEY-----THISISAFAKERSAHASH-----END RSA PRIVATE KEY-----' > /etc/puppetlabs/keymaster/x509/test.example.org/key.pem
echo '-----BEGIN CERTIFICATE REQUEST-----THISISAFAKEHASH-----END CERTIFICATE REQUEST-----' > /etc/puppetlabs/keymaster/x509/test.example.org/request.csr
echo '-----BEGIN CERTIFICATE-----THISISAFAKEHASH-----END CERTIFICATE-----' > /etc/puppetlabs/keymaster/x509/test.example.org/certificate.crt
echo '-----BEGIN CERTIFICATE-----THISISAFAKEPEM-----END CERTIFICATE-----' > /etc/puppetlabs/keymaster/x509/test.example.org/certificate.pem
echo '-----BEGIN CERTIFICATE-----THISISAFAKEP12-----END CERTIFICATE-----' > /etc/puppetlabs/keymaster/x509/test.example.org/certificate.p12
echo '-----BEGIN CERTIFICATE-----THISISAFAKEPFX-----END CERTIFICATE-----' > /etc/puppetlabs/keymaster/x509/test.example.org/certificate.pfx
