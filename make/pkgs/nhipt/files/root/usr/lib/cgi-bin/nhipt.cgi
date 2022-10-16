#!/bin/sh


. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''; log_sys=''; log_int=''; cgi_auto=''; cgi_man=''; log_auto=''; log_man=''; boot_flash=''; boot_usb=''; boot_freetz=''; boot_debug=''
if [ -r /var/tmp/nhipt.par ]; then
	variable=$(cat /var/tmp/nhipt.par)
	for var1 in $variable; do
		export NHIPT_$var1
	done
fi
export cb$NHIPT_DELAY=' selected'
export dsld$NHIPT_DSLDOFF=' checked'

if [ "$NHIPT_LOGTARGET" = "syslog" ]; then log_off=' disabled'; log_dr=' disabled'; log_sys=' checked'; else log_off=''; log_int=' checked'; fi
if [ -n "$(ps | grep -v grep | grep iptlogger)" ]; then log_auto=' checked'; else log_man=' checked'; fi
if [ -n "$(ps | grep -v grep | grep nhipd.pid)" ]; then cgi_auto=' checked'; cgi_dr=' disabled'; else cgi_man=' checked'; cgi_offline=' disabled'; fi
if [ "$NHIPT_BOOT" = "flash" ]; then boot_flash=' checked'; boot_dr=' disabled'; else boot_usb=' checked'; fi
if [ "$NHIPT_BOOTSTRAP" = "freetz" ]; then boot_freetz=' checked'; else boot_debug=' checked'; fi
if [ "$NHIPT_SERVERIP" = "" ]; then NHIPT_SERVERIP=$(ifconfig | grep -v lan:0 | grep -A 2 lan | awk -F'[ :]+' '/inet addr/{print $4}'); fi
if [ "$NHIPT_ADMINIP" = "" ]; then NHIPT_ADMINIP=$REMOTE_ADDR; fi


sec_begin 'NHIPT interface'
cat << EOF
<div style="float: right;"><font size="1">Version 0.8.2h</font></div>
<table border=0 cellpadding=0 cellspacing=0>
<tr>
<th colspan=3>WEB INTERFACE SETTINGS</th>
</tr>
<tr>
<td align=right>Status : </td>
<td>&nbsp;<input type=radio name="start_cgi" value="running" $cgi_auto>running</td>
<td><input type=radio name="start_cgi" value="stopped" $cgi_man>stopped</td>
</tr>
<tr>
<td align=right>Admin IP : </td>
<td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="adminip" value="$(html "$NHIPT_ADMINIP")"></td>
</tr>
<tr>
<td align=right>Server IP :</td>
<td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="serverip" value="$NHIPT_SERVERIP" $cgi_dr></td>
</tr>
<tr>
<td align=right>Server port : </td>
<td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="port" value="$(html "$NHIPT_PORT")" $cgi_dr></td>
</tr>
<tr>
<td align=right>Server root : </td>
<td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="root" value="$(html "$NHIPT_ROOT")" $cgi_dr></td>
</tr>
<tr>
<td align=right>Backup directory : </td>
<td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="back" value="$(html "$NHIPT_BACK")"></td></tr>
<tr>
<td>&nbsp;</td>
<td colspan=2></td>
</tr>
<tr>
<th colspan=3>LOG DEAMON SETTINGS</th>
</tr>
<tr>
<td align=right>Use deamon : </td><td>&nbsp;<input type=radio name="logtarget" value="syslog" $log_sys>syslog</td><td><input type=radio name="logtarget" value="internal" $log_int>internal</td></tr>
<tr>
<td align=right>Status : </td><td>&nbsp;<input type=radio name="start_log" value="running" $log_auto  $log_off>running</td><td><input type=radio name="start_log" value="stopped" $log_man  $log_off>stopped</td></tr>
<tr>
<td align=right>Log directory : </td><td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="logd" $log_dr value="$(html "$NHIPT_LOGD")" ></td></tr>
<tr>
<td>&nbsp;</td><td colspan=2></td></tr>
<tr>
<th colspan=3>BOOT PROCEDURE SETTINGS</th></tr>
<tr>
<td align=right>Boot from : </td>
<td>&nbsp;<input type=radio name="boot" value="flash" $boot_flash>flash</td><td><input type=radio name="boot" value="usb" $boot_usb>usb</td></tr>
<tr>
<td align=right>Bootstrap : </td>
<td>&nbsp;<input type=radio name="bootstrap" value="freetz" $boot_freetz>freetz</td>
<td><input type=radio name="bootstrap" value="debug" $boot_debug>debug.cfg</td>
</tr>
<tr>
<td align=right>Boot directory : </td>
<td colspan=2>&nbsp;&nbsp;<input size=30 type="text" name="bootdir" value="$(html "$NHIPT_BOOTDIR")" $boot_dr></td>
</tr>
<tr>
<td align=right>Boot delay : </td>
<td colspan=2>&nbsp;&nbsp;
<select name="delay">
<option value="0" $cb0>off</option><option value="30"  $cb30>30 s</option>
<option value="60"  $cb60>60 s</option>
<option value="180"  $cb180>3 min</option>
<option value="300"  $cb300>5 min</option>
<option value="600"  $cb600>10 min</option>
</select>
</td>
</tr>
<tr>
<td align=right>Stop dsld while waiting : </td>
<td>&nbsp;<input type=radio name="dsldoff" value="0" $dsld0  $log_off>off</td>
<td><input type=radio name="dsldoff" value="1" $dsld1>on</td>
</tr>
<tr>
<td>&nbsp;</td><td colspan=2></td>
</tr>
<tr>
<td></td>
<td colspan=2>
<INPUT TYPE=BUTTON NAME=FW VALUE="EDIT FIREWALL RULES" $cgi_offline onclick="javascript:nhipt=window.open('http://$NHIPT_SERVERIP:$NHIPT_PORT/cgi-bin/nhipt.cgi','_new');nhipt.focus();">
</td>
</tr>
</table>
EOF
sec_end

