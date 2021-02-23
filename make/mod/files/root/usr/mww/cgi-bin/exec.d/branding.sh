eval "$(modcgi branding mod_cgi)"

cgi_begin "$(lang de:"Branding &auml;ndern" en:"Change branding") ..."
echo "<p>$(lang de:"Um die &Auml;nderungen wirksam zu machen, ist ein Neustart erforderlich." en:"You must reboot the device for the changes to take effect.")</p>"
echo -n '<pre>set branding to '"'$MOD_CGI_BRANDING'"' ... '
success=0
for i in $(ls /usr/www/); do
	case $i in
		all|cgi-bin|css|html|js|kids)
			;;
		*)
			if [ "$i" = "$MOD_CGI_BRANDING" ]; then
				echo "firmware_version $i" > /proc/sys/urlader/environment
				success=1
			fi
			;;
	esac
done
if [ "$success" -eq 1 ]; then
	echo 'done.</pre>'
else
	echo 'failed.</pre>'
fi
back_button mod status
cgi_end
