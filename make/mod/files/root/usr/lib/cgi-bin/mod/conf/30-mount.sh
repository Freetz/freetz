
sec_begin 'Freetzmount'

cgi_print_checkbox_p "stor_uselabel" "$MOD_STOR_USELABEL" \
	"$(lang de:"Partitionsname (falls vorhanden) als Mountpoint nutzen." en:"Use partition label (if defined) as mount point.")"

cgi_print_checkbox_p "stor_autorunend" "$MOD_STOR_AUTORUNEND" \
	"$(lang de:"Automatisch autorun.sh und autoend.sh ausführen." en:"Run autorun.sh and autoend.sh automatically.")"

cgi_print_checkbox_p "stor_killblocker" "$MOD_STOR_KILLBLOCKER" \
	"$(lang de:"Alle Programme beenden die das Aush&auml;ngen verhindern." en:"Kill all programs blocking unmount.")"

cgi_print_textline_p "stor_prefix" "$MOD_STOR_PREFIX" 20 "$(lang de:"Pr&auml;fix f&uuml;r Mountpoints" en:"Prefix for mountpoints") (uStor): "

sec_end
