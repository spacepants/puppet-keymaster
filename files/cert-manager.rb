#! /usr/bin/env ruby
require 'base64'
require 'json'
require 'mixlib/cli'
require 'openssl'
require 'pp'
require 'savon'

class CertManager
  include Mixlib::CLI

  option :authentication,
         description: 'Certificate Manager API authentication config file. Default: /usr/local/etc/cert-manager.json',
         short: '-a AUTH_FILE',
         long: '--auth AUTH_FILE',
         default: '/usr/local/etc/cert-manager.json'

  option :request,
         description: 'Filename of the certificate signing request. Default: request.csr',
         short: '-r CSR_FILE',
         long: '--request CSR_FILE',
         default: 'request.csr'

  option :certificate,
         description: 'Filename of the certificate to create. Default: certificate.pem',
         short: '-c CERT_FILE',
         long: '--cert CERT_FILE',
         default: 'certificate.pem'

  option :cacert,
         description: 'Filename of the certificate authority signing cert for verification',
         short: '-s SIGNING_CERT_FILE',
         long: '--signing-cert SIGNING_CERT_FILE',
         default: '/etc/puppetlabs/keymaster/x509/cacerts/incommon/3-incommon-rsa-server-ca.pem'

  option :id,
         description: 'Certificate ID file. Default: id',
         short: '-i ID_FILE',
         long: '--id ID_FILE',
         default: 'id'

  option :length,
         description: 'Certificate valid term length. (years) Default: 3',
         short: '-l LENGTH',
         long: '--length LENGTH',
         default: '3'

  option :renewid,
         description: 'Renew ID file for the certificate. Default: renewid',
         short: '-w RENEW_ID_FILE',
         long: '--renew-id RENEW_ID_FILE',
         default: 'renewid'

  option :key,
         description: 'Filename of the private key. Default: key.pem',
         short: '-k KEY_FILE',
         long: '--key KEY_FILE',
         default: 'key.pem'

  option :fqdn,
         description: 'Fully qualified domain name for the certificate',
         short: '-n FQDN',
         long: '--name FQDN'

  option :sans,
         description: 'Subject alt names (comma-separated)',
         short: '-z SUBJECT_ALT_NAMES',
         long: '--aliases SUBJECT_ALT_NAMES'

  option :renew,
         description: 'Renew a certificate',
         long: '--renew-cert'

  option :revoke,
         description: 'Revoke a certificate',
         long: '--revoke-cert REVOCATION_REASON'

  option :submit,
         description: 'Submit a new csr',
         long: '--submit-csr'

  option :get,
         description: 'Collect a new certificate',
         long: '--get-cert'

  option :get_renew,
         description: 'Collect a renewed certificate',
         long: '--get-renewed'

  option :test_api,
         description: 'Test the API connection',
         long: '--test-api'

  option :verbose,
         description: 'Enable verbose output',
         short: '-v',
         long: '--verbose'

  option :noop,
         description: 'Enable noop mode',
         long: '--noop'

  option :help,
         :short => "-h",
         :long => "--help",
         :description => "Show this message",
         :on => :tail,
         :boolean => true,
         :show_options => true,
         :exit => 0

  def load_config
    unless File.exists?(config[:authentication])
      abort("Auth config file not found: #{config[:authentication]} Aborting.")
    end
    log "Using auth config file: #{config[:authentication]}"
    file = File.read config[:authentication]
    begin
      data = JSON.parse(file)
    rescue JSON::ParserError
      abort("Could not parse auth config file: #{config[:authentication]} Aborting.")
    end
  end

  def log(msg)
    if config[:verbose]
      puts msg
    end
  end

  def noop(op, msg)
    puts "Running in noop mode. Would have called #{op} with: #{msg.to_s}"
  end

  def get_auth(config_data)
    auth = {
      login: config_data['username'],
      password: config_data['password'],
      customerLoginUri: 'InCommon'
    }
  end

  def get_orgid(config_data)
    orgid = config_data['orgid']
  end

  def get_secret(config_data)
    secret = config_data['secret']
  end

  def get_client
    client = Savon.client(wsdl: 'https://cert-manager.com/ws/EPKIManagerSSL?wsdl')
    client.operations
    return client
  end

  def valid_key
    unless File.exists?(config[:key])
      abort("Key file not found: #{config[:key]} Aborting")
    end
    log "Using key: #{config[:key]}"
    begin
      key = OpenSSL::PKey::RSA.new File.read config[:key]
      if key.private?
        log 'Private key validated successfully'
        return key
      else
        abort('Invalid private key. Aborting')
      end
    rescue OpenSSL::PKey::RSAError
      abort('Invalid key. Aborting')
    end
  end

  def valid_csr
    key = valid_key
    unless File.exists?(config[:request])
      abort("CSR file not found: #{config[:request]} Aborting")
    end
    log "Using csr: #{config[:request]}"
    begin
      csr = OpenSSL::X509::Request.new File.read config[:request]
      if (csr.verify key)
        log 'Certificate signing request verified successfully'
        return csr
      else
        abort('Unable to verify certificate signing request. Aborting.')
      end
    rescue OpenSSL::X509::RequestError
      abort('Invalid certificate signing request. Aborting.')
    end
  end

  def get_fqdn
    unless config[:fqdn]
      abort('No server name provided. Aborting')
    else
      fqdn = config[:fqdn]
    end
  end

  def get_subj_alt_names
    if config[:sans]
      sans = config[:sans]
    else
      sans = ''
    end
  end

  def get_cert_type(fqdn, subj_alt_names)
    if fqdn.split('.')[0] == '*'
      cert_type = {
        id: '227',
        name: 'InCommon Wildcard SSL Certificate (SHA-2)',
        terms: ['1', '2', '3']
      }
    elsif subj_alt_names != ''
      cert_type = {
        id: '226',
        name: 'InCommon Multi Domain SSL (SHA-2)',
        terms: ['1', '2', '3']
      }
    else
      cert_type = {
        id: '224',
        name: 'InCommon SSL (SHA-2)',
        terms: ['1', '2', '3']
      }
    end
  end

  def get_term
    term = config[:length]
  end

  def submit_csr
    client = get_client
    config_data = load_config
    auth = get_auth(config_data)
    orgid = get_orgid(config_data)
    secret = get_secret(config_data)
    csr = valid_csr
    fqdn = get_fqdn
    subj_alt_names = get_subj_alt_names
    cert_type = get_cert_type(fqdn, subj_alt_names)
    term = get_term

    msg = {
      auth_data: auth,
      org_id: orgid,
      secret_key: secret,
      csr: csr,
      phrase: fqdn,
      subj_alt_names: subj_alt_names,
      cert_type: cert_type,
      number_servers: 1,
      server_type: 2,
      term: term,
      comments: "via API for #{fqdn}",
    }

    if config[:noop]
      request = client.build_request(:enroll, message: msg )
      noop('enroll', request.body)
    else
      response = client.call(:enroll, message: msg )
      cert_id = response.body[:enroll_response][:return]

      status_ok(cert_id, 'enroll', 'CSR submission unsuccessful')

      log("CSR successfully submitted. Writing cert ID to #{config[:id]}")
      File.open(config[:id], 'wb') { |f| f.print cert_id }
    end
  end

  def get_id(id_file)
    unless File.exists?(id_file)
      abort("ID file not found: #{id_file} Aborting.")
    end
    log "Using ID file #{id_file}"
    file = File.read id_file
    id = file.chomp
  end

  def is_ready(id, auth)
    client = get_client
    msg = {
      auth_data: auth,
      id: id
    }

    if config[:noop]
      request = client.build_request(:get_collect_status, message: msg )
      noop('get_collect_status', request.body)
      return true
    else
      response = client.call(:get_collect_status, message: msg )
      status = response.body[:get_collect_status_response][:return]

      status_ok(status, 'get_collect_status', "Cert ID #{id} unavailable")
      return true
    end
  end

  def valid_cert(cert, name)
    begin
      good_cert = OpenSSL::X509::Certificate.new cert
    rescue OpenSSL::X509::CertificateError
      abort("Could not validate #{name} certificate. Aborting")
    end
  end

  def verify_cert(cert)
    unless File.exists?(config[:cacert])
      abort("Signing cert file not found: #{config[:cacert]} Aborting.")
    end
    log("Verifying certificate with signing cert: #{config[:cacert]}")
    file = File.read config[:cacert]
    cacert = valid_cert(file, 'signing')
    if cert.verify cacert.public_key
      return true
    else
      abort("Collected certificate could not be verified from InCommon using #{config[:cacert]}. Aborting")
    end
  end

  def get_cert
    client = get_client
    config_data = load_config
    auth = get_auth(config_data)
    id = get_id(config[:id])
    msg = {
      auth_data: auth,
      id: id,
      format_type: 1
    }
    if is_ready(id, auth)
      if config[:noop]
        request = client.build_request(:collect, message: msg )
        noop('collect', request.body)
      else
        response = client.call(:collect, message: msg )
        status = response.body[:collect_response][:return][:status_code]
        status_ok(status, 'collect', "Cert ID #{id} unavailable")
        renewid = response.body[:collect_response][:return][:ssl][:renew_id]
        cert = valid_cert(response.body[:collect_response][:return][:ssl][:certificate], 'collect')

        if verify_cert(cert)
          log("Certificate verified. Writing cert to #{config[:certificate]}")
          File.open(config[:certificate], 'wb') { |f| f.print cert.to_pem }
          log("Writing renew ID to #{config[:renewid]}")
          File.open(config[:renewid], 'wb') { |f| f.print renewid }
        end
      end
    end
  end

  def get_renew_status(renewid)
    begin
      status = File.read 'renew_status'
      log("Renew status file: #{status}")
    rescue Errno::ENOENT
      # if the renew_status file doesn't exist, call renew_cert which creates it
      status = renew_cert(renewid)
      log("Renew status: #{status}")
    end
    status.chomp
  end

  def renew_cert(renewid)
    client = get_client
    msg = { renew_id: renewid }

    if config[:noop]
      request = client.build_request(:renew, message: msg )
      noop('renew', request.body)
      return true
    else
      response = client.call(:renew, message: msg )
      status = response.body[:renew_response][:return]
      status_ok(status, 'renew', "Renewal for ID #{renewid} unsuccessful")

      if status == '0'
        File.open('renew_status', 'wb') { |f| f.print status }
        return status
      else
        return 'nope'
      end
    end
  end

  def get_renewed_cert
    renewid = get_id(config[:renewid])
    renew_status = get_renew_status(renewid)

    log("get_renew_status: #{renew_status}")
    if (renew_status) == '0'
      client = get_client
      msg = {
        renew_id: renewid,
        format_type: 1
      }

      if config[:noop]
        request = client.build_request(:collect_renewed, message: msg )
        noop('collect_renewed', request.body)
      else
        log("Calling collect_renewed.")
        response = client.call(:collect_renewed, message: msg )
        status = response.body[:collect_renewed_response][:return][:error_code]
        log("API returned collect_renewed response code: #{status}")
        b64 = response.body[:collect_renewed_response][:return][:data]
        cert = valid_cert(Base64.decode64(b64), 'collect_renewed')

        if verify_cert(cert)
          log("Certificate verified. Writing cert to #{config[:certificate]}")
          File.open(config[:certificate], 'wb') { |f| f.print cert.to_pem }
          # @TODO The renewed certificate has a different ID from the original request.
          # Unfortunately, get renewed doesn't actually return it for whatever dumb reason.
          # So we'll need some way to indicate that diff.
        end
      end
    else
      # otherwise we don't have a valid renewal to process. pass renew_status to status_ok
      status_ok(renew_status, 'collect_renewed', "Cannot get renewal certificate. Renewal for ID #{renewid} unsuccessful")
    end
  end

  def revoke_cert
    unless config[:revoke]
      abort('Cannot revoke a certificate without a reason.')
    end
    client = get_client
    config_data = load_config
    auth = get_auth(config_data)
    id = get_id(config[:id])
    reason = config[:revoke]
    msg = {
      auth_data: auth,
      id: id,
      reason: reason
    }

    if config[:noop]
      request = client.build_request(:revoke, message: msg )
      noop('revoke', request.body)
    else
      response = client.call(:revoke, message: msg )
      status = response.body[:revoke_response][:return]
      status_ok(status, 'revoke', "Unable to revoke cert id #{id}")
      if status == '0'
        log('Certificate revoked successfully')
      end
    end

  end

  def test_api
    client = get_client
    response = client.call(:get_web_service_info)
    puts response.body[:get_web_service_info_response][:return]
  end

  def status_ok(status, method, msg)
    response_msg = get_response_code(method, status)
    if method == 'renew' || method == 'collect_renewed' || method == 'revoke'
      success = 0
    else
      success = 1
    end
    if status.to_i < success
      abort("#{method}: #{msg}. API returned #{status}: #{response_msg}. Aborting")
    else
      log "#{method}: API returned #{status}"
    end
  end

  def get_response_code(method, code)
    case method
    when 'renew'
      statuses = {
        '0'  => 'Success',
        '-3' => 'Internal error',
        '-4' => 'Invalid renew ID',
      }

    when 'revoke'
      statuses = {
        '0'    => 'Success',
        '-3'   => 'Internal error',
        '-14'  => 'An unknown error occurred',
        '-16'  => 'Permission denied',
        '-40'  => 'Invalid ID',
        '-100' => 'Invalid authentication data for customer',
      }

    when 'collect_renewed'
      statuses = {
        '0'  => 'Issued',
        '-1' => 'Applied',
        '-2' => 'Cert error - invalid state',
        '-3' => 'Internal error',
        '-4' => 'SSL cert does not exist',
        '-5' => 'Waiting for admin approval',
        '-6' => 'Declined by admin',
      }

    else
      statuses = {
        '0'    => 'Certificate being processed by Comodo',
        '1'    => 'Certificate available',
        '-3'   => 'User name invalid',
        '-7'   => 'Country not in ISO-3166 format',
        '-9'   => 'CSR not valid Base64 data',
        '-10'  => 'CSR cannot be decoded',
        '-11'  => 'CSR uses unsupported algorithm',
        '-12'  => 'CSR has invalid signature',
        '-13'  => 'CSR uses unsupported key size',
        '-14'  => 'An unknown error occurred',
        '-16'  => 'Permission denied',
        '-20'  => 'CSR rejected',
        '-21'  => 'Certificate has been revoked',
        '-22'  => 'Still awaiting payment',
        '-23'  => "The certificate hasn't been approved yet",
        '-31'  => 'Invalid email',
        '-32'  => 'Passphrase empty',
        '-33'  => 'Invalid cert type',
        '-34'  => 'Invalid secret key',
        '-35'  => 'Invalid server type',
        '-36'  => 'Invalid term for customer type',
        '-37'  => 'Invalid cert type name',
        '-40'  => 'Invalid ID',
        '-100' => 'Invalid authentication data for customer',
        '-101' => 'Invalid authentication data for customer Organization',
        '-110' => 'Domain is not allowed for customer',
        '-111' => 'Domain is not allowed for customer Organization',
        '-120' => 'Customer configuration is not allowed the requested action',
      }
    end

    msg = statuses[code]
  end
end

mgr = CertManager.new
mgr.parse_options

if mgr.config[:test_api]
  mgr.log 'Testing API connection'
  mgr.test_api
elsif mgr.config[:submit]
  mgr.log 'Beginning csr submission'
  mgr.submit_csr
elsif mgr.config[:get]
  mgr.log 'Beginning cert collection'
  mgr.get_cert
elsif mgr.config[:renew]
  mgr.log 'Beginning cert renewal'
  mgr.renew_cert
elsif mgr.config[:get_renew]
  mgr.log 'Beginning renewed cert collection'
  mgr.get_renewed_cert
elsif mgr.config[:revoke]
  mgr.log "Beginning cert revocation with reason: #{mgr.config[:revoke]}"
  mgr.revoke_cert
end
