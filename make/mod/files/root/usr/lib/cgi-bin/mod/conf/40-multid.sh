sec_begin 'multid'

cat << EOF
<p>$(lang de:"Statt den DNS-Servern des Providers diese nutzen (durch Leerzeichen getrennt)" en:"Use these dns-servers instead of the automatically assigned (seperated by space)"): </p>
<p><input type="text" name="multid_dns" size="55" maxlength="255" value="$(html "$MOD_MULTID_DNS")"></p>
EOF

sec_end
