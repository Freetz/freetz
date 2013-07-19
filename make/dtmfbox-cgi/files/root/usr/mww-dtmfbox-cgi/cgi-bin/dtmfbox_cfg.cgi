#!/bin/sh
DTMFBOX_VERSION="v0.5.0"

if [ -d "/mod/etc/default.dtmfbox" ]; then FREETZ="1"; else FREETZ="0"; fi		# USB/Standalone=0 | Freetz=1

let DTMFBOX_MAX_ACCOUNTS=10							# Max. accounts
let DTMFBOX_MAX_SAVE_LIMIT=61440						# Max. size of /var/flash/debug.cfg
PATH=$PATH:/var/dtmfbox

if [ -f /var/dtmfbox/script.cfg ]; then						# Load script configuration
	. /var/dtmfbox/script.cfg

	if [ "$DTMFBOX_VERSION" != "$DTMFBOX_SCRIPT_VERSION" ];
	then
	    VERSION_DIFFER_TEXT="<p><font color='red'><b>Achtung:<br>Die aktuellen Einstellungen und Skripte sollten zurueckgesetzt werden, da sie nicht mehr aktuell sind!<p>dtmfbox: $DTMFBOX_VERSION<br>Einstellungen: $DTMFBOX_SCRIPT_VERSION<br></b></font>"
	fi
else
	DU="/var/tmp/busybox-tools du"						# Required busybox commands (first time install, when no script.cfg exist)
	FTPPUT="/var/tmp/busybox-tools ftpput"
	GZIP="/var/tmp/busybox-tools gzip"
	GUNZIP="/var/tmp/busybox-tools gunzip"
	HEAD="/var/tmp/busybox-tools head"
	HTTPD="/var/tmp/busybox-httpd httpd"
	MKFIFO="/var/tmp/busybox-tools mkfifo"
	NC="/var/tmp/busybox-tools nc"
	TAIL="/var/tmp/busybox-tools tail"
	TAR="/var/tmp/busybox-tools tar"
	UUDECODE="/var/tmp/busybox-tools uudecode"
	UUENCODE="/var/tmp/busybox-tools uuencode"
fi

# first, try to get real path with realpath command ..
export DTMFBOX_PATH="`realpath /var/dtmfbox 2>/dev/null`"
# .. when this does not work, try to extract realpath with 'ls' command and sed ...
if [ -z "$DTMFBOX_PATH" ] || [ ! -d "$DTMFBOX_PATH" ];
then
	export DTMFBOX_PATH="`ls -l /var/dtmfbox 2>/dev/null | sed 's/^.*->.\(.*\)$/\1/g' 2>/dev/null`"
	if [ -z "$DTMFBOX_PATH" ] || [ ! -d "$DTMFBOX_PATH" ];
	then
		if [ "$FREETZ" = "1" ];
		then
			# Freetz does not need a manual installation.
			# The initial directory is /var/dtmfbox-bin
			export DTMFBOX_PATH=""
		else
			# USB/Standalone needs a manual installation, because rc.dtmfbox script cannot be found.
			# Output an error at the end of this script
			DTMFBOX_INSTALL_ERROR="1"
		fi
	fi
fi

# USB or RAM?
if [ "$DTMFBOX_PATH" = "/var/dtmfbox-bin" ]; then
	DTMFBOX_USB="0";
	ADDITIONAL_CAPTION="(RAM"
else
	if [ ! -z "$DTMFBOX_PATH" ];
	then
		if [ "$DTMFBOX_PATH" = "/usr/bin/dtmfbox-apache" ];
		then
			ADDITIONAL_CAPTION="(APACHE"
			DTMFBOX_APACHE="1"
		else
			ADDITIONAL_CAPTION="(USB"
		fi
		DTMFBOX_USB="1";
	else
		DTMFBOX_USB="0";
		ADDITIONAL_CAPTION="(UNINSTALLED"
	fi
fi

# Stylesheet
#if [ "$FREETZ" = "0" ]; then
	STYLE_CSS="../dtmfbox_style.css";
	ADDITIONAL_CAPITION="$ADDITIONAL_CAPTION)"
	MAIN_CGI="dtmfbox.cgi?pkg=dtmfbox"
#else
#	STYLE_CSS="./dtmfbox_style.css";
#	ADDITIONAL_CAPITION="$ADDITIONAL_CAPTION - Freetz)"
#	MAIN_CGI="pkgconf.cgi?pkg=dtmfbox"
#fi

# When no DTMFBOX_PATH was set, show the page, to setup the path
if [ -z "$DTMFBOX_PATH" ] || [ ! -d "$DTMFBOX_PATH" ];
then
	RESET=$($HTTPD -d "`echo ${QUERY_STRING} | sed -n 's/.*reset_type=\(.*\)/\1/p' | sed -e 's/&.*//g'`")
	if [ "$RESET" != "path" ]; then
		QUERY_STRING="$MAIN_CGI&page=reset_path_only"
	else
		ADDITIONAL_CAPTION="(INSTALLED - Freetz)"
	fi
fi

########################################################################################################################

head_begin() {
#if [ "$FREETZ" = "0" ] || [ "$0" = "dtmfbox.cgi" ]; then
if [ "$0" = "dtmfbox.cgi" ]; then
cat << EOF
Content-Type: text/html


  <!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"
	 "http://www.w3.org/TR/html4/loose.dtd">
  <html>
  <head>
  <meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
  <meta http-equiv="Content-Language" content="de">
  <meta http-equiv="Expires" content="0">
  <meta http-equiv="Pragma" content="no-cache">
  <title>$1</title>
  <style type="text/css">
EOF
#else
#cat << EOF
#  </form>
#  <style type="text/css">
#EOF
fi

cat "$STYLE_CSS"

cat << EOF
  </style>
  </head>
  <body style="overflow-y :scroll;height:100%">
EOF

if [ "$FULLSCREEN" != "1" ]; then
cat << EOF
  <a name="top" href="#top"></a>
  <table border="0" cellspacing="0" cellpadding="0" align="center" width="95%">
  <tr>
  <td bgcolor="white" valign="top" colspan="2">
      <div align="left"><font size="5"><b>dtmfbox</b></font></div>
  </td>
  <td bgcolor="white" valign="bottom">
	<div align="right"><font size="2"><b>$DTMFBOX_VERSION</b><br><font size='1'><b>$ADDITIONAL_CAPITION</b></font></font></div>
  </td>
  </tr>
  <tr><td colspan="3"><hr color="black"></td></tr>
  </table>
EOF
fi

cat << EOF
  <table border="0" cellspacing="0" cellpadding="5" align="center" width="95%" style="table-layout:fixed">
  <tr>
  <td valign="top">
EOF

#if [ "$FREETZ" = "0" ] && [ "$FULLSCREEN" != "1" ]; then echo "<br>"; fi
if [ "$FULLSCREEN" != "1" ]; then echo "<br>"; fi
}

########################################################################################################################

head_end() {

echo "$VERSION_DIFFER_TEXT"

if [ -f "../sWebPhone.jar" ]; then WEBPHONE="<tr><td><a href=\"$MAIN_CGI&page=webphone\">Webphone</a></td></tr>"; fi

#if [ "$FREETZ" = "0" ]; then
echo "</td><td valign='top' width='16%'><br>"
cat << EOF
	  <table class="menu" width="95%">
	  <tr><td><a href="$MAIN_CGI&page=status">Status</a></td></tr>
	  <tr><td><a href="$MAIN_CGI&page=dtmfbox_cfg">Basiseinstellungen</a></td></tr>
	  <tr><td><a href="$MAIN_CGI&page=script_cfg">Skripteinstellungen</a></td></tr>
	  <tr><td><a href="$MAIN_CGI&page=menu_cfg">Menü bearbeiten</a></td></tr>
	  <tr><td><a href="$MAIN_CGI&page=scripts">Skripte bearbeiten</a></td></tr>
	  <tr><td><a href="$MAIN_CGI&page=am_messages">Nachrichten</a></td></tr>
	  $WEBPHONE
	  <tr><td><a href="$MAIN_CGI&page=help" target="_new">Hilfe</a></td></tr>
	  </table><br>
EOF
if [ "$DTMFBOX_APACHE" != "1" ]; then
cat << EOF
	  <table class="menu" width="95%">
	  <tr><td><a href="$MAIN_CGI&page=reset">Pfad, Reset, Uninstall ...</a></td></tr>
	  </table>
EOF
fi
cat << EOF
  </td></tr></table>
  </body>
  </html>
EOF
#else
#  echo "</td></tr></table>"
#fi
}

########################################################################################################################

show_title() {
cat << EOF
    <table border="0" width="95%" bgcolor="#005588">
    <tr><td><font color="white" size="2"><b>$1</b></font></td></tr>
    </table><br>
EOF
}

########################################################################################################################

show_page() {
  CGI_FILE="$1"
  PARAM1="$2"
  PARAM2="$3"
  PARAM3="$4"

  USE_COMPRESSED="1"
  if [ -f "dtmfbox_httpd.tar.gz" ] && [ "$USE_COMPRESSED" = "1" ];
  then
	  $MKFIFO /var/tmp/$CGI_FILE-$REMOTE_ADDR.fifo 2>/dev/null
	  chmod +x /var/tmp/$CGI_FILE-$REMOTE_ADDR.fifo 2>/dev/null
	  $GUNZIP -f -c "dtmfbox_httpd.tar.gz" | $TAR xv -f - -O $CGI_FILE > /var/tmp/$CGI_FILE-$REMOTE_ADDR.fifo &
	  . /var/tmp/$CGI_FILE-$REMOTE_ADDR.fifo "$PARAM1" "$PARAM2" "$PARAM3"
	  rm /var/tmp/$CGI_FILE-$REMOTE_ADDR.fifo 2>/dev/null
  else
	if [ -f "./$CGI_FILE" ];
	then
	  . "./$CGI_FILE" "$PARAM1" "$PARAM2" "$PARAM3"
	else
	  head_begin
	  echo "<b><font color='red' size='3'>Error!<p></p>Cannot find \"$CGI_FILE\" or \"$CGI_FILE.tar.gz\"<br>Current path: \"`pwd`\"</font></b>"
	  head_end
	  exit 1;
	fi
  fi
}

if [ "$DTMFBOX_INSTALL_ERROR" = "1" ];
then
	head_begin
	show_title "Fehler!"
cat << EOF
	dtmfbox wurde nicht korrekt installiert.
EOF
	head_end
	exit
fi
