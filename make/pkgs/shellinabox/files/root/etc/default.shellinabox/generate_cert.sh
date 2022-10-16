cat << 'EOF' > /tmp/openssl_shellinabox.cnf
 [ req ]
 default_bits           = 1024
 default_keyfile        = keyfile.pem
 distinguished_name     = req_distinguished_name
 attributes             = req_attributes
 prompt                 = no
 output_password        = mypass

 [ req_distinguished_name ]
 C                      = DE
 ST                     = Staat
 L                      = Location
 O                      = Organisation
 OU                     = Organisationseinheit
 CN                     = fritz.box
 emailAddress           = test@email.address
 [ req_attributes ]
 challengePassword      = challengepwd
EOF

openssl_req  -x509 -nodes -new -newkey rsa:1024 -keyout /tmp/shellinabox_certificate.pem -out /tmp/shellinabox_certificate.pem -days 7300 -subj "/CN=fritz.box/" -config /tmp/openssl_shellinabox.cnf

rm /tmp/openssl_shellinabox.cnf

