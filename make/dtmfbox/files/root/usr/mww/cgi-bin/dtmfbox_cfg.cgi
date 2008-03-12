#!/var/tmp/sh
package=dtmfbox

if [ -f "/mod/etc/conf/dtmfbox.cfg" ]; then export FREETZ="1"; else export FREETZ="0"; fi

# freetz or standalone/usb ?
if [ "$FREETZ" = "0" ];
then
	if [ ! -f /var/dtmfbox/dtmfbox.save ]; then
		mkdir /var/dtmfbox 2>/dev/null
		cp ../../default.dtmfbox/dtmfbox.cfg /var/dtmfbox/dtmfbox.save
	fi

	# read config
	. /var/dtmfbox/dtmfbox.save

	MAIN_LINK="dtmfbox.cgi?pkg=dtmfbox"
	TABLE_WIDTH="100%"
else
	
	# read config
	. /mod/etc/conf/dtmfbox.cfg

	MAIN_LINK="pkgconf.cgi?pkg=dtmfbox&sort=1"
	TABLE_WIDTH="70%"
fi

if [ "$HIDE_DESIGN" != "1" ];
then
	. ./dtmfbox_lib.cgi
fi

DTMFBOX_VERSION="$DTMFBOX_VERSION"
www_script="$DTMFBOX_WWW/rc.dtmfbox"

MAX_ACCOUNTS=10             # max. number of accounts: 10
MAX_DTMFS=50                # max. number of dtmf-commands: 50
SAVE_PREVIEW=0              # preview of debug.cfg, boot.cfg?

# mod specific settings
if [ "$FREETZ" = "0" ];
then
	HTTPD="busybox-tools httpd"
	NC="busybox-tools nc"
	DU="busybox-tools du"
else
	HTTPD="httpd"
	NC="nc"
	DU="du"
fi
