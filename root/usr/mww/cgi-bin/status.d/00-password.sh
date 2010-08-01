default_password_set() {
	[ "$MOD_HTTPD_PASSWD" == '$1$$zO6d3zi9DefdWLMB.OHaO.' ]
}

if default_password_set; then
	echo '<div style="color: #800000;"><p>$(lang
		de:"Standard-Passwort gesetzt. Bitte
		<a href=\"/cgi-bin/passwd.cgi\">hier</a> &auml;ndern."
		en:"Default password set. Please change
		<a href=\"/cgi-bin/passwd.cgi\">here</a>."
	)</p>'
fi
