[ "${FREETZ_RUN_TELEFON_IN_INHOUSE_MODE}" == "y" ] || return 0

# https://www.ip-phone-forum.de/threads/307385/post-2416060

#since FOS 07-2X
#*CONFIG_BUILDTYPE=998  : {'private','private' }
#*CONFIG_BUILDTYPE=2    : {'beta'   ,'intern  '}
# CONFIG_BUILDTYPE=1000 : {'labor'  ,'inhaus'  }
# CONFIG_BUILDTYPE=1001 : {'labor'  ,'labbeta' }
# CONFIG_BUILDTYPE=1004 : {'labor'  ,'labphone'}
# CONFIG_BUILDTYPE=1005 : {'labor'  ,'labor'   }
# CONFIG_BUILDTYPE=1006 : {'labor'  ,'labtest' }
# CONFIG_BUILDTYPE=1007 : {'labor'  ,'labplus' }
# CONFIG_BUILDTYPE=1    : {'release','release' }

#up to FOS 07-1X
#*CONFIG_RELEASE=0: in-house development version
# CONFIG_RELEASE=1: official release
# CONFIG_RELEASE=2: public beta/labor version

# https://github.com/PeterPawn/modfs/blob/64c6c9a3ea09bdf46a119f80e998dd29d74bd9c2/files/telnetd_by_avm#L25
if grep -a -q CONFIG_BUILDTYPE "${FILESYSTEM_MOD_DIR}/usr/bin/telefon"; then
	var="CONFIG_BUILDTYPE"
	val=998
else
	var="CONFIG_RELEASE"
	val=0
fi

echo1 "forcing telefon daemon to run in in-house mode"
modsed -r \
  "s,^([ \t]*)(telefon[ \t]),\1$var=$val \2," \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.voip" \
  "^[ \t]*$var=$val telefon[ \t]"
