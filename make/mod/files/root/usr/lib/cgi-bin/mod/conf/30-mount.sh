if [ -r /usr/lib/libmodmount.sh ]; then
check "$MOD_STOR_USELABEL" yes:stor_uselabel
check "$MOD_STOR_AUTORUNEND" yes:stor_autorunend
check "$MOD_STOR_KILLBLOCKER" yes:stor_killblocker

sec_begin 'Freetzmount'
cat << EOF
<p>
<input type="hidden" name="stor_uselabel" value="no">
<input id="m1" type="checkbox" name="stor_uselabel" value="yes"$stor_uselabel_chk><label for="m1">$(lang de:"Partitionsname (falls vorhanden) als Mountpoint nutzen." en:"Use partition label (if defined) as mount point.")</label>
</p>
<p>
<input type="hidden" name="stor_autorunend" value="no">
<input id="m2" type="checkbox" name="stor_autorunend" value="yes"$stor_autorunend_chk><label for="m2">$(lang de:"Automatisch autorun.sh und autoend.sh ausführen." en:"Run autorun.sh and autoend.sh automatically.")</label>
</p>
<p>
<input type="hidden" name="stor_killblocker" value="no">
<input id="m3" type="checkbox" name="stor_killblocker" value="yes"$stor_killblocker_chk><label for="m3">$(lang de:"Alle Programme beenden die das Aush&auml;ngen verhindern." en:"Kill all programs blocking unmount.")</label>
</p>
<p>
$(lang de:"Pr&auml;fix f&uuml;r Mountpoints" en:"Prefix for mountpoints") (uStor) : <input type="text" name="stor_prefix" size="20" maxlength="20" value="$(html "$MOD_STOR_PREFIX")"></p>
</p>
EOF
sec_end
fi
