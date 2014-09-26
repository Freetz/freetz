
select "$MOD_STOR_NAMING_SCHEME" FIXED_PREFIX:ns_fixed_prefix VENDOR_PRODUCT:ns_vendor_product "*":ns_partition_label

sec_begin 'Freetzmount'

cat << EOF
<p>
<label for='stor_naming_scheme'>$(lang de:"Mountpoints Namensgebung-Schema" en:"Mount points naming scheme") </label>
<select name='stor_naming_scheme' id='stor_naming_scheme'>
	<option value='PARTITION_LABEL'$ns_partition_label_sel>$(lang de:"Partitionsname" en:"Partition label")</option>
	<option value='FIXED_PREFIX'$ns_fixed_prefix_sel>$(lang de:"Festes Pr&auml;fix" en:"Fixed prefix")</option>
	<option value='VENDOR_PRODUCT'$ns_vendor_product_sel>$(lang de:"Hersteller-Produkt als Pr&auml;fix" en:"Vendor-Product as prefix")</option>
</select>
</p>
EOF

cgi_print_textline_p "stor_prefix" "$MOD_STOR_PREFIX" 20 "$(lang de:"Festes Pr&auml;fix f&uuml;r Mountpoints" en:"Fixed prefix for mount points") (UStor): "

cgi_print_checkbox_p "stor_autorunend" "$MOD_STOR_AUTORUNEND" \
	"$(lang de:"Automatisch autorun.sh und autoend.sh ausf&uuml;hren." en:"Run autorun.sh and autoend.sh automatically.")"

cgi_print_checkbox_p "stor_killblocker" "$MOD_STOR_KILLBLOCKER" \
	"$(lang de:"Alle Programme beenden die das Aush&auml;ngen verhindern." en:"Kill all programs blocking unmount.")"

sec_end
