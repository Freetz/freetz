isFreetzType 7570_IAD || return 0

echo1 "adapt firmware for 7570 IAD"
modsed 's/kernel_start=0x90020000/kernel_start=0x90040000/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/kernel_size=16121856/kernel_size=7995392/' "${FIRMWARE_MOD_DIR}/var/install"
modsed 's/urlader_size=131072/urlader_size=262144/' "${FIRMWARE_MOD_DIR}/var/install"
