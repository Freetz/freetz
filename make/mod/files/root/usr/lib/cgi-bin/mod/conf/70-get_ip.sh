
current_ip_v4="$(get_ip)"
current_ip_v6="$(get_ip --ctlm6)"
current_pre_v6="$(get_ip --ctlmpre6)"
[ -z "$current_ip_v4" ] && current_ip_v4="-$(lang de:"keine" en:"none")-"
[ -z "$current_ip_v6" ] && current_ip_v6="-$(lang de:"keine" en:"none")-"
[ -z "$current_pre_v6" ] && current_pre_v6="-$(lang de:"keine" en:"none")-"

sec_begin 'get_ip'
cat << EOF

<p>
$(lang de:"Immer diese Methode nutzen" en:"Always use this method"): <input type="text" name="get_ip_method" size="20" maxlength="20" value="$(html "$MOD_GET_IP_METHOD")"></p>
</p>

<p>
$(lang de:"Server f&uuml;r STUN/VoIP Methode" en:"Server for STUN/VoIP method"): <input type="text" name="get_ip_stun" size="50" maxlength="250" value="$(html "$MOD_GET_IP_STUN")"></p>
</p>

<p>
<div style='margin-top:6px;'>$(lang de:"M&ouml;gliche Methoden" en:"Available methods"):</div>
<pre>
EOF
get_ip --help | sed -n '5,20p' | html
cat << EOF
</pre>
</p>

<p>
$(lang de:"Ermittelte IPv4" en:"Determined IPv4"): $current_ip_v4
$(lang de:"Ermittelte IPv6" en:"Determined IPv6"): $current_ip_v6
$(lang de:"IPv6 Präfix" en:"IPv6-prefix"): $current_pre_v6
</p>

EOF
sec_end
