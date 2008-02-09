cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/profile
case $tty in
	/dev/pts/*)
		export TERM=xterm-color
		unset serial_term
		;;
	/dev/tts/*|/dev/ttyS0|/dev/console)
		export TERM=vt102
		export serial_term=y
		;;
	*)
		;;
esac

if [ $USER == "root" ] && grep -q '^root:$1$$zO6d3zi9DefdWLMB.OHaO.' /etc/shadow; then
	echo "Default password detected. Please enter a new password for 'root'."
	passwd
	modusers save
	modsave flash
fi
EOF
