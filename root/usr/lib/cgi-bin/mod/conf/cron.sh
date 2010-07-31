check "$MOD_CROND" yes:crond_auto "*":crond_man

sec_begin 'Cron'

cat << EOF
<h2>$(lang de:"Starttyp von crond" en:"crond start type")</h2>
<p>
<input id="c1" type="radio" name="crond" value="yes"$crond_auto_chk><label for="c1"> $(lang de:"Automatisch" en:"Automatic")</label>
<input id="c2" type="radio" name="crond" value="no"$crond_man_chk><label for="c2"> $(lang de:"Manuell" en:"Manual")</label>
</p>
EOF
sec_end
