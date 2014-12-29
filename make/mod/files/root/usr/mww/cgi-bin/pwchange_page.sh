#!/bin/sh

. /usr/lib/libmodcgi.sh

CHALLENGE="$(echo -n "$(date +%s)" | md5sum | sed 's/[ ]*-//')"

cgi_begin '$(lang de:"Passwort &auml;ndern!" en:"Change password!")'
# Waren wir schonmal hier? Dann war was falsch!
[ "$WRONGPW" ] && echo "<b>$(lang de:"altes Passwort war falsch!" en:"Wrong old password!")</b><p>"
[ "$(cat /tmp/flash/mod/webmd5 | tr -d '\n' )" = "465d0ff27bb239292778dc3a0c2f28d9" ] && echo "<b>$(lang de:"Standard Passwort gesetzt. Bitte &auml;ndern!" en:"Default password set! Please change it.")</b><p>"

. /usr/mww/cgi-bin/md5hash.sh
echo "<script>challenge=\"$CHALLENGE\";</script>"

cat << 'EOF'
$(lang de:"Altes Passwort" en:"old password"): <input  type="password" id="old_pw" maxlength="45"><p>
$(lang de:"Neues Passwort" en:"new password"): <input  type="password" id="inp_pw" maxlength="45">
$(lang de:"Wiederholung" en:"retype password"): <input  type="password" id="inp_pw2" maxlength="45"><p>

<script>function checkpw(pw1, pw2){
var ret=true;
if ( pw1 != pw2 ){
	alert( "$(lang de:"PW nicht gleich!" en:"passwords not equal!")");
	ret=false;
 }
else if ( pw1 == "freetz" ){
	alert( "$(lang de:"Bitte nicht das Standardpasswort nutzen!" en:"Don't use default password!")");
	ret=false;
}
return ret;
}</script>

<input type="button" name="go" value="$(lang de:"&Auml;ndern" en:"Change")"
      onclick='if (checkpw (document.getElementById("inp_pw").value , document.getElementById("inp_pw2").value)) {   location.href="/cgi-bin/pwchange.cgi?oldhash="+makemd5(document.getElementById("old_pw").value, challenge)+"&newhash="+md5(document.getElementById("inp_pw").value) ; }'>

EOF

cgi_end

# Wir "merken" uns genau ein "Angebot" 
echo "$CHALLENGE#$REMOTE_ADDR" > /tmp/pwchangesid 

