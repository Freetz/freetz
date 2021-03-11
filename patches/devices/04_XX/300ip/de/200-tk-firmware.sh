# linking tcom-defaults to box-defaults 
ln -sf default.Fritz_Box_FON  "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_Eumex300IP"
ln -sf avm  "${FILESYSTEM_MOD_DIR}/etc/default.Fritz_Box_FON/tcom"
cp ${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.default  ${FILESYSTEM_MOD_DIR}/etc/default.049/fx_lcr.tcom
ln -sf /usr/www/all "${FILESYSTEM_MOD_DIR}/usr/www/tcom"

# to be sure: Add original HWRevision-files from Eumex to rc.init
echo1  "adding HWRevision 78 to rc.init"

cat << 'EOF' >> ${FILESYSTEM_MOD_DIR}/etc/init.d/rc.init
#-------------------------Eumex 300IP---------
HW=78 OEM=all ANNEX=B
HW=78 OEM=all INSTALL_TYPE=ar7_4MB_1eth_3ab_isdn_pots_63151
HW=78 OEM=all VERSION_MAJOR=15
HW=78 OEM=all ROMSIZE=4
HW=78 OEM=all RAMSIZE=16
HW=78 OEM=all CAPI=y CAPI_UBIK=n CAPI_MIPS=y CAPI_XILINX=n CAPI_TE=y CAPI_NT=n CAPI_POTS=y
HW=78 OEM=all FON=y
HW=78 OEM=all WLAN=n WLAN_1130TNET=n WLAN_1350TNET=n
HW=78 OEM=all WLAN_WDS=n
HW=78 OEM=all WLAN_GREEN=n
HW=78 OEM=all DSL=y
HW=78 OEM=all VDSL=n
HW=78 OEM=all ATA=y ATA_FULL=n
HW=78 OEM=all NFS=n
HW=78 OEM=all TR069=n
HW=78 OEM=all UPNP=y
HW=78 OEM=all MAILER=y
HW=78 OEM=all DECT=n
HW=78 OEM=all TAM=n TAM_MODE=0
HW=78 OEM=all JFFS2=n
HW=78 OEM=all BUTTON=n
HW=78 OEM=all UBIK2=n
HW=78 OEM=all VLYNQ=n
HW=78 OEM=all VLYNQ0=0
HW=78 OEM=all VLYNQ1=0
HW=78 OEM=all ASSIST=y
HW=78 OEM=all STOREUSRCFG=y
HW=78 OEM=all PRODUKT=Fritz_Box_FON
HW=78 OEM=all _PRODUKT_NAME=FRITZ!Box#Fon#Eumex300IP
HW=78 OEM=all OEM_DEFAULT=avm
HW=78 OEM=all ETH_COUNT=1
HW=78 OEM=all CDROM=y CDROM_FALLBACK=y
HW=78 OEM=all FIRMWARE_URL=http://www.ip-phone-forum.de/showthread.php?t=97668
HW=78 OEM=all HOSTNAME=eumex.ip
HW=78 OEM=all AB_COUNT=3
HW=78 OEM=all USB=y USB_HOST_TI=n USB_HOST_AVM=n USB_STORAGE=n USB_WLAN_AUTH=n USB_PRINT_SERV=n
HW=78 OEM=all BLUETOOTH=n BLUETOOTH_CTP=n
HW=78 OEM=all AUDIO=n
HW=78 OEM=all XILINX=n
EOF

# patch install script to accept firmware from FBF or Eumex
echo1 "applying install patch"
modpatch "$FIRMWARE_MOD_DIR" "${PATCHES_DIR}/cond/100-aliens/install/install-300ip-as-fon_de.patch" || exit 2

