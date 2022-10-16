#!/bin/sh


. /usr/lib/libmodcgi.sh

act_logoff=''; act_reboot=''; act_shutdown=''; act_poweroff=''
act_standby=''; act_hibernate=''; act_lock=''; act_monoff=''; act_monon=''
[ "$HOL_ACTION" = "logoff" ] && act_logoff=' selected'
[ "$HOL_ACTION" = "reboot" ] && act_reboot=' selected'
[ "$HOL_ACTION" = "shutdown" ] && act_shutdown=' selected'
[ "$HOL_ACTION" = "poweroff" ] && act_poweroff=' selected'
[ "$HOL_ACTION" = "standby" ] && act_standby=' selected'
[ "$HOL_ACTION" = "hibernate" ] && act_hibernate=' selected'
[ "$HOL_ACTION" = "lock" ] && act_lock=' selected'
[ "$HOL_ACTION" = "monitor_off" ] && act_monoff=' selected'
[ "$HOL_ACTION" = "monitor_on" ] && act_monon=' selected'



sec_begin "$(lang de:"Entfernter Rechner" en:"Remote Host")"
cat << EOF
<p>Port: <input type="text" name="port" size="5" maxlength="5" value="$(html "$HOL_PORT")">&nbsp;&nbsp;&nbsp;&nbsp;
Passwort: <input type="password" name="pass" size="20" maxlength="255" value="$(html "$HOL_PASS")"></p>
EOF
sec_end
sec_begin "$(lang de:"Aktionen" en:"Actions")"

cat << EOF
<p>Aktion:

<select name="action" id="action">
<option title="$(lang de:"Abmelden" en:"Log Off")" value="logoff"$act_logoff>$(lang de:"Abmelden" en:"Log Off")</option>
<option title="$(lang de:"Neustart" en:"Reboot")" value="reboot"$act_reboot>$(lang de:"Neustart" en:"Reboot")</option>
<option title="$(lang de:"Herunterfahren" en:"Shutdown")" value="shutdown"$act_shutdown>$(lang de:"Herunterfahren" en:"Shutdown")</option>
<option title="$(lang de:"Hart ausschalten" en:"PowerOff")" value="poweroff"$act_poweroff>$(lang de:"Hart ausschalten" en:"PowerOff")</option>
<option title="$(lang de:"Energie sparen" en:"StandBy")" value="standby"$act_standby>$(lang de:"Energie sparen" en:"StandBy")</option>
<option title="$(lang de:"Ruhezustand" en:"Hibernate")" value="hibernate"$act_hibernate>$(lang de:"Ruhezustand" en:"Hibernate")</option>
<option title="$(lang de:"Sperren" en:"Lock")" value="lock"$act_lock>$(lang de:"Sperren" en:"Lock")</option>
<option title="$(lang de:"Monitor aus" en:"Monitor Off")" value="monitor_off"$act_monoff>$(lang de:"Monitor aus" en:"Monitor Off")</option>
<option title="$(lang de:"Monitor an" en:"Monitor On")" value="monitor_on"$act_monon>$(lang de:"Monitor an" en:"Monitor On")</option>
</select>
&nbsp;&nbsp;&nbsp;&nbsp;
Wartezeit: <input type="text" name="time" size="5" maxlength="5" value="$(html "$HOL_TIME")">&nbsp; Sekunden</p>
<p>$(lang de:"Meldung" en:"Message"):<br>
<textarea name="message" rows="4" cols="50">$(html "$HOL_MESSAGE")</textarea></p>
EOF

sec_end
