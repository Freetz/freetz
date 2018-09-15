#!/usr/bin/env python2

#
# Copyright (c) 2013 freetz.org
#

def menuselect2kconfig(menuselectFilename):
	from xml.dom import minidom
	import re

	missingDependencies = {
		"res_rtp_asterisk": ["WITH_PJPROJECT"]
	}

	selectMap = {
		"CRYPTO": ["FREETZ_LIB_libcrypto"],
		"OPENSSL": ["FREETZ_LIB_libcrypto", "FREETZ_LIB_libssl"],
		"CURL": ["FREETZ_LIB_libcurl"],
		"GSM": ["FREETZ_LIB_libgsm"],
		"ICONV": ["FREETZ_LIB_libiconv if FREETZ_TARGET_UCLIBC_0_9_28"],
		"IKSEMEL": ["FREETZ_LIB_libiksemel"],
		"ILBC": [],
		"IXJUSER": [],
		"PJPROJECT": ["FREETZ_LIB_libpj", "FREETZ_LIB_libpjlib_util", "FREETZ_LIB_libpjnath"],
		"SPANDSP": ["FREETZ_LIB_libspandsp"],
		"SPEEX": ["FREETZ_LIB_libspeex"],
		"SPEEXDSP": ["FREETZ_LIB_libspeexdsp"],
		"SPEEX_PREPROCESS": ["FREETZ_LIB_libspeex"],
		"SYSLOG": [],
		"SQLITE3": ["FREETZ_LIB_libsqlite3"],
		"SRTP": ["FREETZ_LIB_libsrtp", "FREETZ_LIB_libcrypto_WITH_EC"],
		"ZLIB": ["FREETZ_LIB_libz"]
	}

	dependsOnMap = {
		"TIMERFD": ["FREETZ_KERNEL_VERSION_2_6_28_MIN"]
	}

	packagePrefix = "FREETZ_PACKAGE_ASTERISK_"
	withInfix = "WITH_"

	TAG_CATEGORY = "category"
	TAG_MEMBER = "member"
	TAG_DEFAULT_ENABLED = "defaultenabled"
	TAG_DEPEND = "depend"
	TAG_USE = "use"

	ATTR_NAME = "name"
	ATTR_DISPLAYNAME = "displayname"
	ATTR_TYPE = "type"

	categoriesToIgnore = [
		"MENUSELECT_TESTS",
		"MENUSELECT_CFLAGS",
		"MENUSELECT_OPTS_app_voicemail",
		"MENUSELECT_UTILS",
		"MENUSELECT_AGIS",
		"MENUSELECT_EMBED",
		"MENUSELECT_CORE_SOUNDS",
		"MENUSELECT_MOH",
		"MENUSELECT_EXTRA_SOUNDS"
	]

	externalDependencies = set()

	try:
		xmldoc = minidom.parse(menuselectFilename)
	except:
		raise Exception("Failed to read/to parse asterisk menuselect-tree file")

	print "###"
	print "### DO NOT EDIT! This file has been generated."
	print "###"
	print

	for category in xmldoc.getElementsByTagName(TAG_CATEGORY):
		categoryName = category.attributes[ATTR_NAME].value
		if categoryName in categoriesToIgnore:
			continue

		categoryDisplayname = category.attributes[ATTR_DISPLAYNAME].value
		categoryDisplayname = re.sub(" ?[(].*", "", categoryDisplayname) # strip " (...)"-suffix
		print "menu \"" + categoryDisplayname + "\""

		for member in category.getElementsByTagName(TAG_MEMBER):
			defaultEnabledTags = member.getElementsByTagName(TAG_DEFAULT_ENABLED)
			if defaultEnabledTags:
				assert(defaultEnabledTags.length == 1)
				defaultEnabledText = " ".join(t.nodeValue for t in defaultEnabledTags[0].childNodes if t.nodeType == t.TEXT_NODE).upper()
				if defaultEnabledText == "NO":
					continue

			print

			memberName = member.attributes[ATTR_NAME].value
			symbol = packagePrefix + memberName.upper()
			print "\tconfig " + symbol

			memberDisplayname = member.attributes[ATTR_DISPLAYNAME].value
			print "\t\tbool \"" + memberName + ": " + memberDisplayname + "\""
			print "\t\tdefault y"

			for dependencyTag in member.getElementsByTagName(TAG_DEPEND):
				dependencyText = " ".join(t.nodeValue for t in dependencyTag.childNodes if t.nodeType == t.TEXT_NODE).upper()
				isInternalDependency = dependencyText.find("APP_") == 0 or dependencyText.find("CHAN_") == 0 or dependencyText.find("RES_") == 0
				symbol = packagePrefix + ("" if isInternalDependency else withInfix) + dependencyText
				print "\t\tdepends on " + symbol
				if (not isInternalDependency):
					externalDependencies.add(dependencyText)

			if memberName in missingDependencies:
				for depend in missingDependencies[memberName]:
					isInternalDependency = (depend.find(withInfix) != 0)
					symbol = packagePrefix + depend
					print "\t\tdepends on " + symbol
					if (not isInternalDependency):
						externalDependencies.add(depend[len(withInfix):])

			for useTag in member.getElementsByTagName(TAG_USE):
				useText = " ".join(t.nodeValue for t in useTag.childNodes if t.nodeType == t.TEXT_NODE).upper()

				try:
					useType = useTag.attributes[ATTR_TYPE].value.upper()
				except KeyError:
					useType = "EXTERNAL"

				if useType == "EXTERNAL":
					symbol = packagePrefix + withInfix + useText
					print "\t\tdepends on " + symbol
					externalDependencies.add(useText)
				elif useType == "MODULE":
					symbol = packagePrefix + useText
					print "\t\tselect " + symbol
				else:
					raise Exception("Unknown useType")

		print
		print "endmenu"
		print

	for externalDependency in sorted(externalDependencies):
		print "config " + packagePrefix + withInfix + externalDependency
		print "\tbool"
		if externalDependency in dependsOnMap:
			for dependsOn in dependsOnMap[externalDependency]:
				print "\tdepends on " + dependsOn
		if externalDependency in selectMap:
			for select in selectMap[externalDependency]:
				print "\tselect " + select
		print "\tdefault " + ("y" if (externalDependency in dependsOnMap or externalDependency in selectMap) else "n")
		print

def main():
	import sys, os
	import __main__ as main

	if len(sys.argv) != 2:
		print "Usage: " + os.path.basename(main.__file__) + " asterisk-menuselect-tree-file > outfile"
		print "    or \"make asterisk-generate\" in Freetz root directory"
		return

	menuselect2kconfig(sys.argv[1])

if __name__ == "__main__":
	main()
