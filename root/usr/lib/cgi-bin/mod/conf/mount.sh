if [ -r /usr/lib/libmodmount.sh ]; then
check "$MOD_STOR_USELABEL" yes:stor_uselabel

sec_begin 'automount'
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
$(lang de:"Pr&auml;fix f&uuml;r Mountpoints" en:"Prefix for mountpoints") (uStor) : <input type="text" name="stor_prefix" size="20" maxlength="20" value="$(html "$MOD_STOR_PREFIX")"></p>
</p>
EOF
sec_end
fi
