#!/bin/sh

. /usr/lib/libmodcgi.sh

for i in 0 1 2 3 4; do
	eval "mt_service=\$INADYN_MT_SERVICE$i"
	eval "mt_active=\$INADYN_MT_ACTIVE$i"

	check "$mt_active" yes:active$i
	select "$mt_service" \
		dyndns.org:dyndns$i \
		dyndns.org-statdns:dstatdns$i \
		dyndns.org-custom:dcustom$i \
		afraid.org:afraid$i \
		zoneedit.com:zoneedit$i \
		no-ip.com:noip$i \
		tunnelbroker.net:tunnelbroker$i \
		dns.he.net:dnshenet$i \
		changeip.com:changeip$i \
		spdyn.de:spdyn$i \
		userdefined:userdef$i
done

for i in 0 1 2 3 4 5; do
	select "$INADYN_MT_VERBOSE" "$i":verbose${i}
done

sec_begin "$(lang de:"Starttyp" en:"Start type")"

cgi_print_radiogroup_service_starttype "enabled" "$INADYN_MT_ENABLED" "" "" 0

sec_end

sec_begin "$(lang de:"Inadyn-Daemon" en:"Inadyn-Daemon")"

cat << EOF
<p>$(lang de:"Log-Level" en:"Verbosity level") :
<select name='verbose'>
<OPTION value="0"$verbose0_sel>0</OPTION>
<OPTION value="1"$verbose1_sel>1</OPTION>
<OPTION value="2"$verbose2_sel>2</OPTION>
<OPTION value="3"$verbose3_sel>3</OPTION>
<OPTION value="4"$verbose4_sel>4</OPTION>
<OPTION value="5"$verbose5_sel>5</OPTION>
</SELECT></p>

<script>
function changeaccount(value) {
	document.getElementById("Account0").style.display = "none";
	document.getElementById("Account1").style.display = "none";
	document.getElementById("Account2").style.display = "none";
	document.getElementById("Account3").style.display = "none";
	document.getElementById("Account4").style.display = "none";

	switch (value) {
		case "0":
			document.getElementById("Account0").style.display = "block";
			break;
		case "1":
			document.getElementById("Account1").style.display = "block";
			break;
		case "2":
			document.getElementById("Account2").style.display = "block";
			break;
		case "3":
			document.getElementById("Account3").style.display = "block";
			break;
		case "4":
			document.getElementById("Account4").style.display = "block";
			break;
		}

}

document.write("<p><SELECT NAME='dynaccount' onChange='changeaccount(value)'>" +
"<OPTION VALUE='0'>Account 0</OPTION>" +
"<OPTION VALUE='1'>Account 1</OPTION>" +
"<OPTION VALUE='2'>Account 2</OPTION>" +
"<OPTION VALUE='3'>Account 3</OPTION>" +
"<OPTION VALUE='4'>Account 4</OPTION>" +
"</SELECT></p>");

document.write("<div id='Account0' style='display:block'>" +
"<table id='mdns0' style='margin: auto'>" +
  "<tr>" +
    "<td>$(lang de:"DNS Service" en:"DNS Service") : </td>" +
    "<td><SELECT NAME='service0'>" +
      "<OPTION VALUE='dyndns.org' $dyndns0_sel>dyndns.org</OPTION>" +
      "<OPTION VALUE='dyndns.org-statdns' $dstatdns0_sel>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE='dyndns.org-custom' $dcustom0_sel>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE='afraid.org' $afraid0_sel>afraid.org</OPTION>" +
      "<OPTION VALUE='zoneedit.com' $zoneedit0_sel>zoneedit.com</OPTION>" +
      "<OPTION VALUE='no-ip.com' $noip0_sel>no-ip.com</OPTION>" +
      "<OPTION VALUE='tunnelbroker.net' $tunnelbroker0_sel>tunnelbroker.net</OPTION>" +
      "<OPTION VALUE='dns.he.net' $dnshenet0_sel>dns.he.net</OPTION>" +
      "<OPTION VALUE='changeip.com' $changeip0_sel>changeip.com</OPTION>" +
      "<OPTION VALUE='spdyn.de' $spdyn0_sel>spdyn.de</OPTION>" +
      "<OPTION VALUE='userdefined' $userdef0_sel>$(lang de:"Benutzerdefiniert" en:"User defined")</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r05'>$(lang de:"Custom URL" en:"Custom URL") : </label></td>" +
    "<td><input id='r05' type='text' name='url0' size='45' maxlength='255' value='$(html "$INADYN_MT_URL0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r01'>$(lang de:"Benutzername" en:"Username") : </label></td>" +
    "<td><input id='r01' type='text' name='user0' size='45' maxlength='255' value='$(html "$INADYN_MT_USER0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r02'>$(lang de:"Passwort" en:"Password") : </label></td>" +
    "<td><input id='r02' type='password' name='pass0' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r03'>$(lang de:"Alias" en:"Alias") : </label></td>" +
    "<td><input id='r03' type='text' name='alias0' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r04'>$(lang de:"Optionen" en:"Options") : </label></td>" +
    "<td><input id='r04' type='text' name='options0' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS0")'></td>" +
  "</tr>" +
"</table>" +
"<p><input type='hidden' name='active0' value='no'><input id='a0' type='checkbox' name='active0' value='yes'$active0_chk><label for='a0'> $(lang de:"Account aktiv" en:"Account enabled")</label></p>" +
"</div>");

document.write("<div id='Account1' style='display:none'>" +
"<table id='mdns1' style='margin: auto'>" +
  "<tr>" +
    "<td>$(lang de:"DNS Service" en:"DNS Service") : </td>" +
    "<td><SELECT NAME='service1'>" +
      "<OPTION VALUE='dyndns.org' $dyndns1_sel>dyndns.org</OPTION>" +
      "<OPTION VALUE='dyndns.org-statdns' $dstatdns1_sel>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE='dyndns.org-custom' $dcustom1_sel>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE='afraid.org' $afraid1_sel>afraid.org</OPTION>" +
      "<OPTION VALUE='zoneedit.com' $zoneedit1_sel>zoneedit.com</OPTION>" +
      "<OPTION VALUE='no-ip.com' $noip1_sel>no-ip.com</OPTION>" +
      "<OPTION VALUE='tunnelbroker.net' $tunnelbroker1_sel>tunnelbroker.net</OPTION>" +
      "<OPTION VALUE='dns.he.net' $dnshenet1_sel>dns.he.net</OPTION>" +
      "<OPTION VALUE='changeip.com' $changeip1_sel>changeip.com</OPTION>" +
      "<OPTION VALUE='spdyn.de' $spdyn1_sel>spdyn.de</OPTION>" +
      "<OPTION VALUE='userdefined' $userdef1_sel>$(lang de:"Benutzerdefiniert" en:"User defined")</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r15'>$(lang de:"Custom URL" en:"Custom URL") : </label></td>" +
    "<td><input id='r15' type='text' name='url1' size='45' maxlength='255' value='$(html "$INADYN_MT_URL1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r11'>$(lang de:"Benutzername" en:"Username") : </label></td>" +
    "<td><input id='r11' type='text' name='user1' size='45' maxlength='255' value='$(html "$INADYN_MT_USER1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r12'>$(lang de:"Passwort" en:"Password") : </label></td>" +
    "<td><input id='r12' type='password' name='pass1' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r13'>$(lang de:"Alias" en:"Alias") : </label></td>" +
    "<td><input id='r13' type='text' name='alias1' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r14'>$(lang de:"Optionen" en:"Options") : </label></td>" +
    "<td><input id='r14' type='text' name='options1' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS1")'></td>" +
  "</tr>" +
"</table>" +
"<p><input type='hidden' name='active1' value='no'><input id='a1' type='checkbox' name='active1' value='yes'$active1_chk><label for='a1'> $(lang de:"Account aktiv" en:"Account enabled")</label></p>" +
"</div>");

document.write("<div id='Account2' style='display:none'>" +
"<table id='mdns2' style='margin: auto'>" +
  "<tr>" +
    "<td>$(lang de:"DNS Service" en:"DNS Service") : </td>" +
    "<td><SELECT NAME='service2'>" +
      "<OPTION VALUE='dyndns.org' $dyndns2_sel>dyndns.org</OPTION>" +
      "<OPTION VALUE='dyndns.org-statdns' $dstatdns2_sel>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE='dyndns.org-custom' $dcustom2_sel>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE='afraid.org' $afraid2_sel>afraid.org</OPTION>" +
      "<OPTION VALUE='zoneedit.com' $zoneedit2_sel>zoneedit.com</OPTION>" +
      "<OPTION VALUE='no-ip.com' $noip2_sel>no-ip.com</OPTION>" +
      "<OPTION VALUE='tunnelbroker.net' $tunnelbroker2_sel>tunnelbroker.net</OPTION>" +
      "<OPTION VALUE='dns.he.net' $dnshenet2_sel>dns.he.net</OPTION>" +
      "<OPTION VALUE='changeip.com' $changeip2_sel>changeip.com</OPTION>" +
      "<OPTION VALUE='spdyn.de' $spdyn2_sel>spdyn.de</OPTION>" +
      "<OPTION VALUE='userdefined' $userdef2_sel>$(lang de:"Benutzerdefiniert" en:"User defined")</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r25'>$(lang de:"Custom URL" en:"Custom URL") : </label></td>" +
    "<td><input id='r25' type='text' name='url2' size='45' maxlength='255' value='$(html "$INADYN_MT_URL2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r21'>$(lang de:"Benutzername" en:"Username") : </label></td>" +
    "<td><input id='r21' type='text' name='user2' size='45' maxlength='255' value='$(html "$INADYN_MT_USER2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r22'>$(lang de:"Passwort" en:"Password") : </label></td>" +
    "<td><input id='r22' type='password' name='pass2' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r23'>$(lang de:"Alias" en:"Alias") : </label></td>" +
    "<td><input id='r23' type='text' name='alias2' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r24'>$(lang de:"Optionen" en:"Options") : </label></td>" +
    "<td><input id='r24' type='text' name='options2' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS2")'></td>" +
  "</tr>" +
"</table>" +
"<p><input type='hidden' name='active2' value='no'><input id='a2' type='checkbox' name='active2' value='yes'$active2_chk><label for='a2'> $(lang de:"Account aktiv" en:"Account enabled")</label></p>" +
"</div>");


document.write("<div id='Account3' style='display:none'>" +
"<table id='mdns3' style='margin: auto'>" +
  "<tr>" +
    "<td>$(lang de:"DNS Service" en:"DNS Service") : </td>" +
    "<td><SELECT NAME='service3'>" +
      "<OPTION VALUE='dyndns.org' $dyndns0_sel>dyndns.org</OPTION>" +
      "<OPTION VALUE='dyndns.org-statdns' $dstatdns3_sel>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE='dyndns.org-custom' $dcustom3_sel>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE='afraid.org' $afraid3_sel>afraid.org</OPTION>" +
      "<OPTION VALUE='zoneedit.com' $zoneedit3_sel>zoneedit.com</OPTION>" +
      "<OPTION VALUE='no-ip.com' $noip3_sel>no-ip.com</OPTION>" +
      "<OPTION VALUE='tunnelbroker.net' $tunnelbroker3_sel>tunnelbroker.net</OPTION>" +
      "<OPTION VALUE='dns.he.net' $dnshenet3_sel>dns.he.net</OPTION>" +
      "<OPTION VALUE='changeip.com' $changeip3_sel>changeip.com</OPTION>" +
      "<OPTION VALUE='spdyn.de' $spdyn3_sel>spdyn.de</OPTION>" +
      "<OPTION VALUE='userdefined' $userdef3_sel>$(lang de:"Benutzerdefiniert" en:"User defined")</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r35'>$(lang de:"Custom URL" en:"Custom URL") : </label></td>" +
    "<td><input id='r35' type='text' name='url3' size='45' maxlength='255' value='$(html "$INADYN_MT_URL3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r31'>$(lang de:"Benutzername" en:"Username") : </label></td>" +
    "<td><input id='r31' type='text' name='user3' size='45' maxlength='255' value='$(html "$INADYN_MT_USER3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r32'>$(lang de:"Passwort" en:"Password") : </label></td>" +
    "<td><input id='r32' type='password' name='pass3' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r33'>$(lang de:"Alias" en:"Alias") : </label></td>" +
    "<td><input id='r33' type='text' name='alias3' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r34'>$(lang de:"Optionen" en:"Options") : </label></td>" +
    "<td><input id='r34' type='text' name='options3' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS3")'></td>" +
  "</tr>" +
"</table>" +
"<p><input type='hidden' name='active3' value='no'><input id='a3' type='checkbox' name='active3' value='yes'$active3_chk><label for='a3'> $(lang de:"Account aktiv" en:"Account enabled")</label></p>" +
"</div>");


document.write("<div id='Account4' style='display:none'>" +
"<table id='mdns4' style='margin: auto'>" +
  "<tr>" +
    "<td>$(lang de:"DNS Service" en:"DNS Service") : </td>" +
      "<td><SELECT NAME='service4'>" +
      "<OPTION VALUE='dyndns.org' $dyndns4_sel>dyndns.org</OPTION>" +
      "<OPTION VALUE='dyndns.org-statdns' $dstatdns4_sel>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE='dyndns.org-custom' $dcustom4_sel>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE='afraid.org' $afraid4_sel>afraid.org</OPTION>" +
      "<OPTION VALUE='zoneedit.com' $zoneedit4_sel>zoneedit.com</OPTION>" +
      "<OPTION VALUE='no-ip.com' $noip4_sel>no-ip.com</OPTION>" +
      "<OPTION VALUE='tunnelbroker.net' $tunnelbroker4_sel>tunnelbroker.net</OPTION>" +
      "<OPTION VALUE='dns.he.net' $dnshenet4_sel>dns.he.net</OPTION>" +
      "<OPTION VALUE='changeip.com' $changeip4_sel>changeip.com</OPTION>" +
      "<OPTION VALUE='spdyn.de' $spdyn4_sel>spdyn.de</OPTION>" +
      "<OPTION VALUE='userdefined' $userdef4_sel>$(lang de:"Benutzerdefiniert" en:"User defined")</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r45'>$(lang de:"Custom URL" en:"Custom URL") : </label></td>" +
    "<td><input id='r45' type='text' name='url4' size='45' maxlength='255' value='$(html "$INADYN_MT_URL4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r41'>$(lang de:"Benutzername" en:"Username") : </label></td>" +
    "<td><input id='r41' type='text' name='user4' size='45' maxlength='255' value='$(html "$INADYN_MT_USER4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r42'>$(lang de:"Passwort" en:"Password") : </label></td>" +
    "<td><input id='r42' type='password' name='pass4' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r43'>$(lang de:"Alias" en:"Alias") : </label></td>" +
    "<td><input id='r43' type='text' name='alias4' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r44'>$(lang de:"Optionen" en:"Options") : </label></td>" +
    "<td><input id='r44' type='text' name='options4' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS4")'></td>" +
  "</tr>" +
"</table>" +
"<p><input type='hidden' name='active4' value='no'><input id='a4' type='checkbox' name='active4' value='yes'$active4_chk><label for='a4'> $(lang de:"Account aktiv" en:"Account enabled")</label></p>" +
"</div>");

</script>
EOF

sec_end
