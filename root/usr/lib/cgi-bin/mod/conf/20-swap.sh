check "$MOD_SWAP" yes:swap_auto "*":swap_man

sec_begin 'Swap'

cat << EOF
<h2>$(lang de:"Starttyp von swap" en:"swap start type")</h2>
<p>
<input id="s1" type="radio" name="swap" value="yes"$swap_auto_chk><label for="s1"> $(lang de:"Aktiviert" en:"Activated")</label>
<input id="s2" type="radio" name="swap" value="no"$swap_man_chk><label for="s2"> $(lang de:"Deaktiviert" en:"Deactivated")</label>
</p>
<h2>$(lang de:"Swap-Datei" en:"Swap file") ($(lang de:"Beispiel:" en:"e.g.") /var/media/ftp/uStor01/swapfile $(lang de:"oder" en:"or") /dev/sda1)</h2>
<p>$(lang de:"Pfad" en:"Path"): <input type="text" name="swap_file" size="50" maxlength="255" value="$(html "$MOD_SWAP_FILE")"></p>
<p>$(lang de:"Gr&ouml;&szlig;e" en:"Size"): <input type="text" name="swap_size" size="3" maxlength="4" value="" /> MB <input type="button" value="$(lang de:"Swap-Datei anlegen" en:"Create swap file")" onclick="window.open('/cgi-bin/create_swap.cgi?swap_file='+encodeURIComponent(document.forms[0].swap_file.value)+'&swap_size='+encodeURIComponent(document.forms[0].swap_size.value),'swapfilepopup','menubar=no,width=800,height=600,toolbar=no,resizable=yes,scrollbars=yes')" /></p>
EOF

sec_end
