#!/bin/sh

# CONFIGURATION

script_folder=/var/packages/PlexMediaServer/home/Plex\ Media\ Server
# Domain Name for naming file and cert conversion
domain_name=**SET VALUE**
# p12 file
p12_file_path="$script_folder/$domain_name.pfx"
# p12 password
p12cert_password=**SET VALUE**
# Synology's Default Let's encrypt folder
letsencrypt_cert_folder=/usr/syno/etc/certificate/system/default
# renew timestamp
renew_timestamp=renew_plex_timestamp


# DO NOT CHANGE BELOW UNLESS YOU'RE A WIZARD

generate_p12=false
current_date=`date +"%s"`
current_certificate_date=`openssl x509 -enddate -noout -in "$letsencrypt_cert_folder/RSA-cert.pem" | cut -d'=' -f2`
current_certificate_timestamp=`date -d "$current_certificate_date" +"%s"`

# check if the renew_timestamp file exists
if [ ! -f "$script_folder/$renew_timestamp" ]; then
  echo "Generate timestamp for the current renew date... "
  echo "$current_certificate_timestamp" > "$script_folder/$renew_timestamp"
  chmod +rw "$script_folder/$renew_timestamp"
  chown admin:users "$script_folder/$renew_timestamp"

  # generate the first p12 file
  generate_p12=true
else
  renew_date=`cat "$script_folder/$renew_timestamp"`
  # check if it is necessary to renew the certificate or not
  if expr "$current_date" ">" "$renew_date" > /dev/null; then
    # generate a new p12 file
    echo "Renewing certificate..."
    generate_p12=true

    # update timestamp in the file
    echo $current_certificate_timestamp > "$script_folder/$renew_timestamp"
  else
    echo "It is not necessary to renew the certificate, abort."
    exit 0
  fi
fi

# generate a new certificate file if necessary, and restart Plex
if expr "$generate_p12" "=" "true" > /dev/null; then
  echo "Generating the p12 certificate file..."
  openssl pkcs12 -export -out "$p12_file_path" \
    -in "$letsencrypt_cert_folder/RSA-cert.pem" \
    -inkey "$letsencrypt_cert_folder/RSA-privkey.pem" \
    -certfile "$letsencrypt_cert_folder/RSA-fullchain.pem" \
    -name "$domain_name" -password pass:$p12cert_password
  chmod +r "$p12_file_path"
  chown admin:users "$p12_file_path"
  echo "Restarting Plex Media Server..."
  /bin/systemctl restart pkgctl-PlexMediaServer
  echo "Done."
fi
