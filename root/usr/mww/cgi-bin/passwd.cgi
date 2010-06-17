#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi_begin 'Passwort' 'password'

cat << EOF
<script type=text/javascript>
function CheckInput(form) {
	password=form.password;
	replay=form.replay;
	if (password.value=="") {
		alert("$(lang de:"Passwort leer!" en:"Empty password!")");
		password.focus();
		return false;
	} else if (replay.value=="") {
		alert("$(lang de:"Passwort leer!" en:"Empty password!")");
		replay.focus();
		return false;
	} else if (password.value != replay.value) {
		alert("$(lang de:"Passw&ouml;rter stimmen nicht &uuml;berein!" en:"Passwords do not match!")");
		password.focus();
		return false;
	} else {
		return true;
	}
}
</script>

<h1>$(lang de:"Passwort &auml;ndern" en:"Change password")</h1>

<form action="/cgi-bin/passwd_save.cgi" method=POST onsubmit="return CheckInput(document.forms[0])">
<table border="0" cellspacing="1" cellpadding="0">
<tr><td>$(lang de:"altes Passwort: " en:"old password ")</td><td><input type="password" size=20 name="oldpassword"></td></tr>
<tr><td>$(lang de:"neues Passwort: " en:"new password ")</td><td><input type="password" size=20 name="password"></td></tr>
<tr><td>$(lang de:"Wiederholung: " en:"new password ")</td><td><input type="password" size=20 name="replay"></td></tr>
</table>
<input type="submit" value="$(lang de:"Speichern" en:"Save")">
</form>
EOF
	
cgi_end
