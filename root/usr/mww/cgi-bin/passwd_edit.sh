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

<form method=POST onsubmit="return CheckInput(this)">
<table>
<tr><td><label for="oldpassword">$(lang de:"Altes Passwort: " en:"Old password ")</label></td><td><input type="password" size=20 name="oldpassword" id="oldpassword"></td></tr>
<tr><td><label for="password">$(lang de:"Neues Passwort: " en:"New password ")</label></td><td><input type="password" size=20 name="password" id="password"></td></tr>
<tr><td><label for="replay">$(lang de:"Wiederholung: " en:"new password ")</label></td><td><input type="password" size=20 name="replay" id="replay"></td></tr>
</table>
<input type="submit" value="$(lang de:"Speichern" en:"Save")">
</form>
EOF

cgi_end
