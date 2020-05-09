# Synology Plex Cert Autorenew
Script to automatically renew plex ssl certificate using the Synology LetsEncrypt certificate.

First, this script was originally created by [ryansully](https://gist.github.com/ryansully/) but he seems to have removed it and replaced it with one for Sickrage.  I tweaked it slightly to work with the Plex cert setup instructions from [Karsten Pearce](https://www.cascadingfalls.com/2017/06/using-lets-encrypt-for-plex-on-synology/).

If you have a LetsEncrypt SSL certificate setup on your Synology it autorenews every 3 months.  Whenever that certificate renews this will automatically update the certificate Plex is using.  Just set it up to run daily in the task scheduler.

```#!/bin/sh

# CONFIGURATION

script_folder=/var/services/homes/plex
# Domain Name for naming file and cert conversion
domain_name=**SET VALUE**
# p12 file
p12_file_path=$script_folder/$domain_name.pfx
# p12 password
p12cert_password=**SET VALUE**
# Synology's Default Let's encrypt folder
letsencrypt_cert_folder=/usr/syno/etc/certificate/system/default
# renew timestamp
renew_timestamp=renew_plex_timestamp


# DO NOT CHANGE BELOW UNLESS YOU'RE A WIZARD

generate_p12=false
current_date=`date +"%s"`
current_certificate_date=`openssl x509 -enddate -noout -in $letsencrypt_cert_folder/cert.pem | cut -d'=' -f2`
current_certificate_timestamp=`date -d "$current_certificate_date" +"%s"`

# check if the renew_timestamp file exists
if [ ! -f $script_folder/$renew_timestamp ]; then
  echo "Generate timestamp for the current renew date... "
  echo $current_certificate_timestamp > $script_folder/$renew_timestamp
  chmod +rw $script_folder/$renew_timestamp
  chown admin:users $script_folder/$renew_timestamp

  # generate the first p12 file
  generate_p12=true
else
  renew_date=`cat $script_folder/$renew_timestamp`
  # check if it is necessary to renew the certificate or not
  if expr "$current_date" ">" "$renew_date" > /dev/null; then
    # generate a new p12 file
    echo "Renewing certificate..."
    generate_p12=true

    # update timestamp in the file
    echo $current_certificate_timestamp > $script_folder/$renew_timestamp
  else
    echo "It is not necessary to renew the certificate, abort."
    exit 0
  fi
fi

# generate a new certificate file if necessary, and restart Plex
if expr "$generate_p12" "=" "true" > /dev/null; then
  echo "Generating the p12 certificate file..."
  openssl pkcs12 -export -out $p12_file_path -in $letsencrypt_cert_folder/cert.pem -inkey $letsencrypt_cert_folder/privkey.pem -certfile $letsencrypt_cert_folder/chain.pem -name "$domain_name" -password pass:$p12cert_password
  chmod +r $p12_file_path
  chown admin:users $p12_file_path
  echo "Restarting Plex Media Server..."
  sh /var/packages/Plex\ Media\ Server/scripts/start-stop-status stop
  sh /var/packages/Plex\ Media\ Server/scripts/start-stop-status start
  echo "Done."
fi
```
