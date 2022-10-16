cgi_begin "$(lang de:"Attribute bereinigen" en:"Clean up attributes")"
echo "<p>$(lang de:"Entfernt Merker f&uuml;r \"nicht unterst&uuml;tzte &Auml;nderungen\"" en:"Cleans up marker for \"unauthorized changes\"")</p>"
echo -n "<pre>$(lang de:"Bereinige Attribute" en:"Cleaning up attributes") ..."
major=$(grep tffs /proc/devices)
tffs_major=${major%%tffs}
rm -f /var/flash/fw_attrib
mknod /var/flash/fw_attrib c $tffs_major 87
echo -n "" > /var/flash/fw_attrib
rm -f /var/flash/fw_attrib
echo " $(lang de:"fertig" en:"done").</pre>"
back_button mod status
cgi_end
