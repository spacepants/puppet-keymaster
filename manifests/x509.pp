# keymaster::x509
#
# Manages the creation, generation, and deletion of x509 certs on the keymaster
#
# @param $common_name Common name of the certificate. Required.
# @param $ensure Whether the cert should be present. Defaults to 'present'.
# @param $country Country code in ISO-3166 format. Optional.
# @param $organization Name of organization for cert. Optional.
# @param $state State for cert. Optional.
# @param $locality Locality for cert. Optional.
# @param $aliases Any additional aliases to include as subject alt names. Optional.
# @param $email Email address for cert. Optional.
# @param $days Cert valid duration in days, if self signed. Defaults to '365'.
# @param $term Cert valid duration in years, if not self signed. Defaults to '3'.
# @param $length RSA key size. Defaults to '4096'.
# @param $self_signed Should this be a self-signed certificate. Defaults to false.
#
define keymaster::x509 (
  String                                    $common_name,
  Enum['present', 'absent']                 $ensure       = 'present',
  Optional[String]                          $country      = undef,
  Optional[String]                          $organization = undef,
  Optional[String]                          $state        = undef,
  Optional[String]                          $locality     = undef,
  Array                                     $aliases      = [],
  Optional[String]                          $email        = undef,
  String                                    $days         = '365',
  String                                    $term         = '3',
  String                                    $length       = '4096',
  Boolean                                   $self_signed  = false,
) {

  if $ensure == 'present' {
    $file_ensure = 'file'
    $dir_ensure = 'directory'
  }
  else {
    $file_ensure = 'absent'
    $dir_ensure = 'absent'
  }

  $clean_name = regsubst($name, '[*]', 'wild', 'G')

  # Set resource defaults
  Exec { path => "${::keymaster::ruby_path}:/usr/bin:/usr/sbin:/bin:/sbin" }

  File {
    owner => $::keymaster::user,
    group => $::keymaster::group,
    mode  => '0640',
  }

  # Define some paths
  $cert_src_dir      = "${::keymaster::keystore_x509}/${clean_name}"
  $cert_cnf_file     = "${cert_src_dir}/config.cnf"
  $cert_key_file     = "${cert_src_dir}/key.pem"
  $cert_csr_file     = "${cert_src_dir}/request.csr"
  $cert_id_file      = "${cert_src_dir}/id"
  $cert_renewid_file = "${cert_src_dir}/renewid"
  $cert_pem_file     = "${cert_src_dir}/certificate.pem"


  # Create the x509 store directory
  file{"x509_${clean_name}_dir":
    ensure => $dir_ensure,
    path   => $cert_src_dir,
    mode   => '0750',
  }

  # Create cnf
  file{"x509_${clean_name}_cnf":
    ensure  => $file_ensure,
    path    => $cert_cnf_file,
    content => template('keymaster/config.cnf.erb'),
  }

  if $ensure == 'present' {
    # Create private key
    exec{"x509_${clean_name}_key":
      command => "openssl genrsa -out ${cert_key_file} ${length}",
      user    => $::keymaster::user,
      group   => $::keymaster::group,
      creates => $cert_key_file,
      require => File["x509_${clean_name}_cnf"],
      before  => File["x509_${clean_name}_key"],
    }
    # Create certificate signing request
    exec{"x509_${clean_name}_csr":
      command => "openssl req -new -key ${cert_key_file} -out ${cert_csr_file} -config ${cert_cnf_file}",
      user    => $::keymaster::user,
      group   => $::keymaster::group,
      creates => $cert_csr_file,
      require => File["x509_${clean_name}_key"],
      before  => File["x509_${clean_name}_csr"],
    }

    if $self_signed {
      exec{"x509_${clean_name}_pem":
        command => "openssl x509 -req -days ${days} -in ${cert_csr_file} -signkey ${cert_key_file} -out ${cert_pem_file}",
        user    => $::keymaster::user,
        group   => $::keymaster::group,
        creates => $cert_pem_file,
        require => File["x509_${clean_name}_csr"],
        before  => File["x509_${clean_name}_pem"],
      }
    }
    else {
      $alias_string = join($aliases, ',')
      if $alias_string != '' {
        $alias_param = " --aliases \"${alias_string}\""
      }
      else {
        $alias_param = ''
      }

      # Submit CSR
      exec{"x509_${clean_name}_submit_csr":
        command => "ruby /usr/local/bin/cert-manager.rb --submit-csr --name ${common_name}${alias_param} --term ${term}",
        cwd     => $cert_src_dir,
        user    => $::keymaster::user,
        group   => $::keymaster::group,
        creates => $cert_id_file,
        require => File["x509_${clean_name}_csr"],
        before  => File["x509_${clean_name}_id"],
      }

      file{"x509_${clean_name}_id":
        ensure => $file_ensure,
        path   => $cert_id_file,
      }

      # Get certificate
      exec{"x509_${clean_name}_pem":
        command => 'ruby /usr/local/bin/cert-manager.rb --get-cert',
        cwd     => $cert_src_dir,
        user    => $::keymaster::user,
        group   => $::keymaster::group,
        creates => $cert_pem_file,
        require => File["x509_${clean_name}_id"],
        before  => [
          File["x509_${clean_name}_pem"],
          File["x509_${clean_name}_renewid"],
        ],
      }

      file{"x509_${clean_name}_renewid":
        ensure => $file_ensure,
        path   => $cert_renewid_file,
      }
    }
  }

  file{"x509_${clean_name}_key":
    ensure => $file_ensure,
    path   => $cert_key_file,
  }

  file{"x509_${clean_name}_csr":
    ensure => $file_ensure,
    path   => $cert_csr_file,
  }

  file{"x509_${clean_name}_pem":
    ensure => $file_ensure,
    path   => $cert_pem_file,
  }
}
