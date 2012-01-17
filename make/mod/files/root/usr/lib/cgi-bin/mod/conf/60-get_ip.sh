
current_ip="$(get_ip)"
[ -z "$current_ip" ] && current_ip="-$(lang de:"keine" en:"none")-"

sec_begin 'get_ip'
cat << EOF

<p>
$(lang de:"Immer diese Methode nutzen" en:"Always use this method"): <input type="text" name="get_ip_method" size="20" maxlength="20" value="$(html "$MOD_GET_IP_METHOD")"></p>
</p>

<p>
<div style='margin-top:6px;'>$(lang de:"M&ouml;gliche Methoden" en:"Available methods"):</div>
<pre>
EOF
get_ip --help | sed -nr 's/    -.,()/\1/p' | html
cat << EOF
</pre>
</p>

<p>
$(lang de:"Ermittelte IP" en:"Determined IP"): $current_ip
</p>

EOF
sec_end
