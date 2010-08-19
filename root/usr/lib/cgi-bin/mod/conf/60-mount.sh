if [ -r /usr/lib/libmodmount.sh ]; then
check "$MOD_STOR_USELABEL" yes:stor_uselabel
check "$MOD_STOR_AUTORUNEND" yes:stor_autorunend

sec_begin 'automount (FREETZ-MOUNT)'
if [ -x /usr/sbin/blkid ]; then
cat << EOF
<p>
<input type="hidden" name="stor_uselabel" value="no">
<input id="m1" type="checkbox" name="stor_uselabel" value="yes"$stor_uselabel_chk><label for="m1">$(lang de:"Partitionname (falls vorhanden) als Mountpoint" en:"Use partition label (if defined) as mount point")</label>
</p>
EOF
fi
cat << EOF
<p>
<input type="hidden" name="stor_autorunend" value="no">
<input id="m2" type="checkbox" name="stor_autorunend" value="yes"$stor_autorunend_chk><label for="m2">$(lang de:"Automatisch autrun.sh und autoend.sh ausführen." en:"Run autorun.sh and autoend.sh automatically.")</label>
</p>
<p>
$(lang de:"Pr&auml;fix f&uuml;r Mountpoints" en:"Prefix for mountpoints") (uStor) : <input type="text" name="stor_prefix" size="20" maxlength="20" value="$(html "$MOD_STOR_PREFIX")"></p>
</p>
EOF
sec_end
fi
