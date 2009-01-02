#!/bin/sh

[ -z "$1" ] || [ -z "$2" ] && exit 1

append() {
	cat <<EOF

choice
	prompt "Printer Type"
	depends on FREETZ_PACKAGE_HPLIP && $1
	help
		Select your printer type here.

EOF

	for printer in $2; do
		PRTR=`echo $printer | tr a-z- A-Z_`
		echo -e "\tconfig FREETZ_HPLIP_PRINTER_TYPE_$PRTR"
		echo -e "\t\tbool \"$printer\""
	done

	echo "endchoice"
}

_IFS="$IFS"
IFS=""
printers=`awk '/^\[.*[^~]\]$/ { gsub(/\[|\]/, ""); print }' < "$2"`
deskjets=`echo $printers | grep deskjet`
photosmarts=`echo $printers | grep photosmart`
officejets=`echo $printers | grep officejet`
pscs=`echo $printers | grep psc`
laserjets=`echo $printers | grep laserjet | grep -v color_laserjet`
claserjets=`echo $printers | grep color_laserjet`
others=`echo $printers | grep -vE 'deskjet|photosmart|officejet|psc|laserjet'`
IFS="$_IFS"

cat <<EOF
config FREETZ_PACKAGE_HPLIP
	bool "HPLIP $1 (binary only)"
	default n
	select FREETZ_PACKAGE_SANE_BACKENDS
	help
		HPLIP - HP Linux Imaging and Printing

choice
	prompt "Printer Class"
	depends on FREETZ_PACKAGE_HPLIP
	help
		Select your printer class here.

	config FREETZ_PACKAGE_HPLIP_DESKJET
	bool "Deskjet"

	config FREETZ_PACKAGE_HPLIP_PHOTOSMART
	bool "Photosmart"

	config FREETZ_PACKAGE_HPLIP_OFFICEJET
	bool "Officejet"

	config FREETZ_PACKAGE_HPLIP_PSC
	bool "PSC"

	config FREETZ_PACKAGE_HPLIP_LASERJET
	bool "LaserJet"

	config FREETZ_PACKAGE_HPLIP_COLOR_LASERJET
	bool "Color LaserJet"

	config FREETZ_PACKAGE_HPLIP_OTHER
	bool "Other"
endchoice
EOF

append "FREETZ_PACKAGE_HPLIP_DESKJET" "$deskjets"
append "FREETZ_PACKAGE_HPLIP_PHOTOSMART" "$photosmarts"
append "FREETZ_PACKAGE_HPLIP_OFFICEJET" "$officejets"
append "FREETZ_PACKAGE_HPLIP_PSC" "$pscs"
append "FREETZ_PACKAGE_HPLIP_LASERJET" "$laserjets"
append "FREETZ_PACKAGE_HPLIP_COLOR_LASERJET" "$claserjets"
append "FREETZ_PACKAGE_HPLIP_OTHER" "$others"

cat <<EOF

config FREETZ_HPLIP_PRINTER_TYPE
	string
EOF

for printer in $printers; do
    PRTR=`echo $printer | tr a-z- A-Z_`
    echo -e "\tdefault \"$printer\" if FREETZ_HPLIP_PRINTER_TYPE_$PRTR"
done
