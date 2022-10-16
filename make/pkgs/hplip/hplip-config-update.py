#!/usr/bin/env python
# -*- coding: utf-8 -*-
from sys import argv, stdout, stderr, exit
import re
from collections import defaultdict

# To ease search in menuconfig, the printers are split into these classes
# mind the order (e.g. color_laserjet before laserjet)
# format: (substring of section name in  models.dat, string for "Printer Class" in menuconfig)
classes = [
    ("deskjet",         "Deskjet"),
    ("photosmart",      "Photosmart"),
    ("officejet",       "Officejet"),
    ("psc",             "PSC"),
    ("color_laserjet",  "Color LaserJet"),
    ("laserjet",        "LaserJet"),
    ("designjet",       "Designjet"),
    ("",                "Other") # default, "" matches every section name
]

def parse(models_dat):
    # format:
    # >>> allprinters["officejet"]["officejet_pro_8000_a809"]
    # ['HP Officejet Pro 8000 Printer - A809a', 'HP Officejet Pro 8000 Wireless Printer - A809n']
    allprinters = defaultdict(dict)
    with open(models_dat) as fp:
        for line in fp:
            match = re.match(r"\[(.*[^~])\]", line)
            if match:
                pr = match.group(1) # don't touch this string; used by awk to strip down models.dat
                for cl, name in classes:
                    if cl in line:
                        break
                allprinters[cl][pr] = []
            else:
                match = re.match(r"model\d*=(.*)", line)
                if match:
                    allprinters[cl][pr].append(match.group(1))
    return allprinters

def tovar(s):
    """Transform s into a valid identifier for Kconfig by making it uppercase and
    replacing everything that is not a letter, digit or underscore with an underscore"""
    return re.sub(r"[^A-Z\d_]", "_", s.upper())

def print_class(cl, printers):
    stdout.write("""\

choice
	prompt "Printer Type"
	depends on FREETZ_PACKAGE_HPLIP && FREETZ_PACKAGE_HPLIP_%s
	help
		Select your printer type here.

""" % tovar(cl))

    for typ in sorted(printers.keys()):
        stdout.write("""\
	config FREETZ_PACKAGE_HPLIP_PRINTER_TYPE_%s
		bool "%s"
		help
			Supported models:
			%s

""" % (tovar(typ), typ, "\n\t\t\t".join(printers[typ])))

    stdout.write("""\
endchoice
""")


if __name__ == "__main__":
    if len(argv) != 3:
        stderr.write("Usage: %s <hplip version> <model.dat>\n" % argv[0])
        exit(1)

    version = argv[1]
    allprinters = parse(argv[2])

    stdout.write("""\
config FREETZ_PACKAGE_HPLIP
	bool "HPLIP %s (binary only)"
	select FREETZ_PACKAGE_SANE_BACKENDS
	select FREETZ_LIB_libpthread
	select FREETZ_LIB_libusb_1
	default n
	help
		HPLIP - HP Linux Imaging and Printing

choice
	prompt "Printer Class"
	depends on FREETZ_PACKAGE_HPLIP
	help
		Select your printer class here.
""" % version)

    #classes[4],classes[5]=classes[5],classes[4]
    for cl, name in classes:
        stdout.write("""\

	config FREETZ_PACKAGE_HPLIP_%s
	bool "%s"
""" % (tovar(name), name))

    stdout.write("""\
endchoice
""")

    for cl, name in classes:
        print_class(name, allprinters[cl])


    stdout.write("""\

config FREETZ_PACKAGE_HPLIP_PRINTER_TYPE
	string
""")

    for cl, name in classes:
        for pr in allprinters[cl].keys():
            stdout.write("""\
	default "%s" if FREETZ_PACKAGE_HPLIP_PRINTER_TYPE_%s
""" % (pr, tovar(pr)))
