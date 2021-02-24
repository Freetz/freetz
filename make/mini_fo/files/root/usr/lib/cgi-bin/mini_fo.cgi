#!/bin/sh


. /usr/lib/libmodcgi.sh
storage=$(/mod/etc/init.d/rc.mini_fo store | grep "mini_fo=" | sed -e "s/mini_fo=//")
boot=$(/mod/etc/init.d/rc.mini_fo bootstatus)

check "$storage" "":none ram "*":jffs2
check "$boot" enabled:boot "*":noboot

sec_begin "$(lang de:"Speicherort" en:"Storage location")"

if ! $(grep -q jffs2 /proc/mtd); then
	jffs2_disabled=" disabled"
fi

cat << EOF
<p>
<input id="l1" type="radio" name="storage" value=""$none_chk><label for="l1"> $(lang de:"Nicht konfiguriert" en:"Not configured")</label>
<input id="l2" type="radio" name="storage" value="ram"$ram_chk><label for="l2"> RAM ($(lang de:"fl&uuml;chtiger Speicher" en:"volatile memory"))</label>
<input id="l3" type="radio" name="storage" value="jffs2"$jffs2_chk$jffs2_disabled><label for="l2"> JFFS2 ($(lang de:"dauerhafter Speicher" en:"persistent storage"))</label>
</p>
EOF

sec_end
sec_begin "$(lang de:"Mini_fo beim Booten aktivieren" en:"Activate mini_fo at boot time")"

cat << EOF
<p>
<input id="b1" type="radio" name="boot" value="enabled"$boot_chk><label for="b1"> $(lang de:"Aktiviert" en:"Enabled")</label>
<input id="b2" type="radio" name="boot" value="disabled"$noboot_chk><label for="b2"> $(lang de:"Deaktiviert" en:"Disabled")</label>
</p>
EOF

sec_end

cat << EOF
<p>$(lang de:"&Auml;nderungen werden erst nach einem Neustart aktiv, auch wenn hier bereits die neuen Werte angezeigt werden." en:"Changes will take effect after a reboot, even if new settings will already be displayed here.")</p>
EOF
