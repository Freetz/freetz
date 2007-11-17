if [ "$DS_TYPE_SPEEDPORT_W707V" == "y" ]; then
    if [ -z "$FIRMWARE2" ]; then
	echo "ERROR: no tk firmware" 1>&2
	exit 1
    fi
    echo1 "adapt firmware for W701V"

    echo2 "copying W701V files"
    cp "${DIR}/.tk/original/filesystem/etc/led.conf" "${FILESYSTEM_MOD_DIR}/etc/led.conf"
    cp "${DIR}/.tk/original/filesystem/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet/Piglet.ko" \
	    "${FILESYSTEM_MOD_DIR}/lib/modules/2.6.13.1-ohio/kernel/drivers/char/Piglet"
    cp "${DIR}/.tk/original/filesystem/lib/modules/microvoip_isdn_top.bit"* "${FILESYSTEM_MOD_DIR}/lib/modules"

    echo2 "moving default config dir, creatinh tcom and congstar symlinks"
    ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"
    ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/congstar"
    mv "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_7170" "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V"
    ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/tcom"
    ln -sf avm "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_SpeedportW701V/congstar"

    echo2 "patching rc.S and rc.init"
    sed -i -e "s/piglet_bitfile_offset=0 /piglet_bitfile_offset=0x51 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
    sed -i -e "s/piglet_irq_gpio=18 /piglet_enable_button2=1 /" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
    sed -i -e "/modprobe Piglet piglet_bitfile.*$/i \
	 piglet_load_params=\"\$piglet_load_params piglet_enable_switch=1\"" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
    sed -i -e "/piglet_irq=9.*$/d" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.S"
    
    if [ -e "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init" ]; then
	sed -i -e "s/^HW=94/HW=101/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
	sed -i -e "s/PRODUKT_NAME=\".*$/PRODUKT_NAME=\"FRITZ!Box#Fon#Speedport#W#701V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
	sed -i -e "s/PRODUKT=\".*$/PRODUKT=\"Fritz_Box_SpeedportW701V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init"
    else
    	sed -i -e "s/CONFIG_PRODUKT_NAME=\".*$/CONFIG_PRODUKT_NAME=\"FRITZ!Box Fon Speedport W701V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
	sed -i -e "s/CONFIG_PRODUKT=\".*$/CONFIG_PRODUKT=\"Fritz_Box_SpeedportW701V\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"
    fi
    echo2 "patching webinterface"
    sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/sip1.js"
    sed -i -e "s/<? setvariable var:showtcom 0 ?>/<? setvariable var:showtcom 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/fon/siplist.js"
    sed -i -e "s/<? setvariable var:allprovider 0 ?>/<? setvariable var:allprovider 1 ?>/g" "${FILESYSTEM_MOD_DIR}/usr/www/all/html/de/internet/authform.html"
fi