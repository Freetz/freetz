[ -n "${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}" ] || return 0

for oem in $(supported_brandings); do
	if [ "${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}" == "$oem" ]; then
		echo1 "hardcoding branding in /etc/init.d/rc.conf to '${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}'"
		sed -e 's/^\([ \t]*export OEM\)$/\1='"${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}"'/' -i "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
		return 0
	fi
done

error 1 "selected branding '${FREETZ_ENFORCE_FIRMWARE_VERSION_VIA_RCCONF}' is not supported by this firmware"
