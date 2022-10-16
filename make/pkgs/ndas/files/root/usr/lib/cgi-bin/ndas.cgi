#!/bin/sh

. /usr/lib/libmodcgi.sh

select "$NDAS_ACCESSMODE" w:am_rw "*":am_ro

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$NDAS_ENABLED" "" "" 0
sec_end


sec_begin "$(lang de:"Einstellungen" en:"Settings")"

cgi_print_textline_p "id"                 "$(html "$NDAS_ID")"                 29 "$(lang de:"NDAS Ger&auml;te-ID" en:"NDAS Device-ID"): "
cgi_print_textline_p "numberofpartitions" "$(html "$NDAS_NUMBEROFPARTITIONS")"  2 "$(lang de:"Anzahl der Partitionen" en:"Number of Partitions"): " "" number
cat <<- EOF
<p>
<label for='accessmode'>$(lang de:"Zugriffsmodus" en:"Access Mode"): </label>
<select name='accessmode' id='accessmode'>
	<option value='r'$am_ro_sel>$(lang de:"Nur lesend" en:"Read-only")</option>
	<option value='w'$am_rw_sel>$(lang de:"Lesend und schreibend" en:"Read/Write")</option>
</select>
</p>
EOF
cgi_print_textline_p "writekey"  "$(html "$NDAS_WRITEKEY")"   5 "$(lang de:"Schreibschl&uuml;ssel" en:"Write Key"): "
cgi_print_textline_p "interface" "$(html "$NDAS_INTERFACE")" 16 "$(lang de:"NDAS Netzwerk Interface" en:"NDAS Network Interface"): "

i=1
while [ $i -le "$NDAS_NUMBEROFPARTITIONS" ]; do
	cgi_print_textline_p "mountcmd$i" "$(eval html "\${NDAS_MOUNTCMD${i}}")" 50/60 "$(lang de:"Mount-Befehl f&uuml;r Partition nda$i" en:"Mount command for partition nda$i"): "
	let i++
done

[ -e /mod/etc/init.d/rc.samba ] && cgi_print_checkbox_p "restart_smb" "$NDAS_RESTART_SMB" "$(lang de:"Samba-Dienst neu starten" en:"Restart the Samba service") "
[ -e /mod/etc/init.d/rc.nfsd  ] && cgi_print_checkbox_p "restart_nfs" "$NDAS_RESTART_NFS" "$(lang de:"NFS-Dienst neu starten" en:"Restart the NFS service") "

sec_end
