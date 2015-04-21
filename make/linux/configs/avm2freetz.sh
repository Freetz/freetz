#!/bin/bash

#
# this script is intended to be used for (semi-)automatic conversion of AVM kernel .config to the Freetz one
#
# not (yet) suitable for production use, WORK IN PROGRESS
#

usage() {
cat << EOF

Usage: ${SELF} TODO
EOF
}

join() {
	(IFS="$1"; shift; echo -n "$*")
}

_if_disabled_impl() {
	local value="$1"; shift
	if [ "$1" == "--append" -o "$1" == "-a" ]; then
		local append="$2"; shift 2
	fi
	sed -r -e 's,^# ('$(join $'|' "$@")') is not set$,\1='"${value}${append:+\n}${append}"','
}

m_if_disabled() {
	_if_disabled_impl m "$@"
}

y_if_disabled() {
	_if_disabled_impl y "$@"
}

fs_related() {
	m_if_disabled -a "CONFIG_EXT2_FS_XATTR=y" CONFIG_EXT2_FS | m_if_disabled CONFIG_FS_MBCACHE \
	| \
	m_if_disabled -a "CONFIG_EXT3_FS_XATTR=y" CONFIG_EXT3_FS | m_if_disabled CONFIG_FS_MBCACHE CONFIG_JBD \
	| \
	m_if_disabled -a "CONFIG_EXT4_FS_XATTR=y" CONFIG_EXT4_FS | m_if_disabled CONFIG_FS_MBCACHE CONFIG_JBD2 CONFIG_CRC16 \
	| \
	m_if_disabled CONFIG_AUTOFS4_FS CONFIG_CODA_FS CONFIG_FAT_FS CONFIG_MSDOS_FS CONFIG_VFAT_FS \
	| \
	m_if_disabled CONFIG_CIFS \
	| \
	m_if_disabled CONFIG_HFS_FS CONFIG_HFSPLUS_FS \
	| \
	m_if_disabled CONFIG_NLS_CODEPAGE_437 \
	| \
	m_if_disabled CONFIG_NLS_ISO8859_1 \
	| \
	m_if_disabled CONFIG_NLS_ISO8859_15 \
	| \
	m_if_disabled CONFIG_NLS_UTF8
}

block_related() {
	m_if_disabled CONFIG_MTD_BLOCK2MTD
}

SELF=$(basename "$0")

fs_related | block_related
