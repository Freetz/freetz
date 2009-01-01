#!/bin/sh

[ -z "$1" ] || [ -z "$2" ] && exit 1

cat <<EOF
config FREETZ_PACKAGE_HPLIP
	bool "HPLIP $1 (binary only)"
	default n
	select FREETZ_PACKAGE_SANE_BACKENDS
	help
		HPLIP - HP Linux Imaging and Printing

choice
	prompt "Printer Type"
	depends on FREETZ_PACKAGE_HPLIP
	help
		Select your printer type here.

EOF

for printer in `awk '/^\[.*[^~]\]$/ { gsub(/\[|\]/, ""); print }' < "$2"`; do
    PRTR=`echo $printer | tr a-z A-Z`
    echo "config FREETZ_HPLIP_PRINTER_TYPE_$PRTR"
    echo "	bool \"$printer\""
done

cat <<EOF
endchoice

config FREETZ_HPLIP_PRINTER_TYPE
	string
EOF

for printer in `awk '/^\[.*[^~]\]$/ { gsub(/\[|\]/, ""); print }' < "$2"`; do
    PRTR=`echo $printer | tr a-z A-Z`
    echo "	default \"$printer\" if FREETZ_HPLIP_PRINTER_TYPE_$PRTR"
done
