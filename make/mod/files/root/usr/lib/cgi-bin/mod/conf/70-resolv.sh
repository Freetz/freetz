
sec_begin 'resolv.conf'
cat << EOF

<p>
$(lang de:"Diesen DNS-Server in die /etc/resolv.conf eintragen" en:"Write this dns server to /etc/resolv.conf"): <input type="text" name="resolv_dns" size="15" maxlength="15" value="$(html "$MOD_RESOLV_DNS")"></p>
</p>

<p>
$(lang
de:"Dies &auml;ndert den DNS-Server den die Box selbst zur Namensaufl&ouml;sung benutzt. Es wird kein Upstream-Nameserver eines installierten DNS-Servers ver&auml;ndert, noch hat es Auswirkungen auf andere Ger&auml;te im Netzwerk."
en:"This changed the DNS server the box uses itself for name resolution. Neither a upstream name server of a installed dns server will be modified, nor anything of name resolution for other devices at the local network."
)
</p>


EOF
sec_end
