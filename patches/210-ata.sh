if  [ "$DS_PATCH_ATA" == "y" ]
then
	# patch by supamicha
	# http://www.ip-phone-forum.de/showthread.php?t=95855
	[ "$DS_VERBOSITY_LEVEL" -ge 1 ] && echo "${L1}applying ata patch"
	sed -i -e "s/...echo..var.isAta.../1/g" "${HTML_MOD_DIR}/internet/internet_expert.js"
fi
