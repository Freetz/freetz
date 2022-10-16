
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
get_ip --help | sed -nr '/^ *-h/d;s/    [- ][0-9 a-z][, ]()/\1/p' | html
cat << EOF
</pre>
</p>

EOF
sec_end

