check "$MOD_TELNETD" yes:telnetd_auto inetd:telnetd_inetd "*":telnetd_man

sec_begin 'Telnet'

cat << EOF
<h2>$(lang de:"Starttyp von telnetd" en:"telnetd start type")</h2>
<p>
<input id="t1" type="radio" name="telnetd" value="yes"$telnetd_auto_chk><label for="t1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="t2" type="radio" name="telnetd" value="no"$telnetd_man_chk><label for="t2"> $(lang de:"Manuell" en:"Manual")</label>
EOF
if $inetd; then
cat << EOF
<input id="t3" type="radio" name="telnetd" value="inetd"$telnetd_inetd_chk><label for="t3"> $(lang de:"Inetd" en:"Inetd")</label>
EOF
fi
cat << EOF
</p>
EOF

sec_end
