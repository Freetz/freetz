#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

check "$INADYN_MT_ENABLED" yes:auto "*":man

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
		benutzerdefiniert:userdef$i
done

for i in 0 1 2 3 4 5; do
    	select "$INADYN_MT_VERBOSE" "$i":verbose${i}_sel
done

sec_begin 'Starttyp'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatisch</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manuell</label>
</p>
EOF

sec_end

sec_begin 'Inadyn-Daemon'

cat << EOF
<p>Verbose Level : 
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
	document.getElementById("Acount0").style.display = "none";
	document.getElementById("Acount1").style.display = "none";
	document.getElementById("Acount2").style.display = "none";
	document.getElementById("Acount3").style.display = "none";
	document.getElementById("Acount4").style.display = "none";

	switch (value) {
		case "0":
			document.getElementById("Acount0").style.display = "block";
			break;
		case "1":
			document.getElementById("Acount1").style.display = "block";
			break;
		case "2":
			document.getElementById("Acount2").style.display = "block";
			break;
		case "3":
			document.getElementById("Acount3").style.display = "block";
			break;
		case "4":
			document.getElementById("Acount4").style.display = "block";
			break;
		}

}

function changeservice(value) {
	document.getElementById("dyndns.org").style.display = "none";
	document.getElementById("dyndns.org-statdns").style.display = "none";
	document.getElementById("dyndns.org-custom").style.display = "none";
	document.getElementById("afraid.org").style.display = "none";
	document.getElementById("zoneedit.com").style.display = "none";
	document.getElementById("no-ip.com").style.display = "none";
	document.getElementById("benutzerdefiniert").style.display = "none";
	
	switch (value) {
		case "0":
			document.getElementById("dyndns.org").style.display = "block";
			break;
		case "1":
			document.getElementById("dyndns.org-statdns").style.display = "block";
			break;
		case "2":
			document.getElementById("dyndns.org-custom").style.display = "block";
			break;
		case "3":
			document.getElementById("afraid.org").style.display = "block";
			break;
		case "4":
			document.getElementById("zoneedit.com").style.display = "block";
			break;
		case "5":
			document.getElementById("no-ip.com").style.display = "block";
			break;
		case "6":
			document.getElementById("benutzerdefiniert").style.display = "block";
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

document.write("<div id='Acount0' style='display:block'>" +
"<table id='mdns0' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service0' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns0_sel='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns0_sel='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom0_sel='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid0_sel='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit0_sel='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip0_sel='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef0_sel='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r05'>Custom URL : </label></td>" +
    "<td><input id='r05' type='text' name='url0' size='45' maxlength='255' value='$(html "$INADYN_MT_URL0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r01'>Username : </label></td>" +
    "<td><input id='r01' type='text' name='user0' size='45' maxlength='255' value='$(html "$INADYN_MT_USER0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r02'>Passwort : </label></td>" +
    "<td><input id='r02' type='password' name='pass0' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r03'>Alias : </label></td>" +
    "<td><input id='r03' type='text' name='alias0' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r04'>Optionen : </label></td>" + 
    "<td><input id='r04' type='text' name='options0' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS0")'></td>" + 
  "</tr>" + 
"</table>" + 
"<p><input type='hidden' name='active0' value='no'><input id='a0' type='checkbox' name='active0' value='yes'$active0_chk><label for='a0'> Account aktiv</label></p>" +
"</div>");

document.write("<div id='Acount1' style='display:none'>" +
"<table id='mdns1' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service1' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns1_sel='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns1_sel='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom1_sel='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid1_sel='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit1_sel='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip1_sel='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef1_sel='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r15'>Custom URL : </label></td>" +
    "<td><input id='r15' type='text' name='url1' size='45' maxlength='255' value='$(html "$INADYN_MT_URL1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r11'>Username : </label></td>" +
    "<td><input id='r11' type='text' name='user1' size='45' maxlength='255' value='$(html "$INADYN_MT_USER1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r12'>Passwort : </label></td>" +
    "<td><input id='r12' type='password' name='pass1' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r13'>Alias : </label></td>" +
    "<td><input id='r13' type='text' name='alias1' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r14'>Optionen : </label></td>" + 
    "<td><input id='r14' type='text' name='options1' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS1")'></td>" + 
  "</tr>" + 
"</table>" + 
"<p><input type='hidden' name='active1' value='no'><input id='a1' type='checkbox' name='active1' value='yes'$active1_chk><label for='a1'> Account aktiv</label></p>" +
"</div>");

document.write("<div id='Acount2' style='display:none'>" +
"<table id='mdns2' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service2' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns2_sel='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns2_sel='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom2_sel='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid2_sel='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit2_sel='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip2_sel='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef2_sel='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r25'>Custom URL : </label></td>" +
    "<td><input id='r25' type='text' name='url2' size='45' maxlength='255' value='$(html "$INADYN_MT_URL2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r21'>Username : </label></td>" +
    "<td><input id='r21' type='text' name='user2' size='45' maxlength='255' value='$(html "$INADYN_MT_USER2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r22'>Passwort : </label></td>" +
    "<td><input id='r22' type='password' name='pass2' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r23'>Alias : </label></td>" +
    "<td><input id='r23' type='text' name='alias2' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r24'>Optionen : </label></td>" + 
    "<td><input id='r24' type='text' name='options2' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS2")'></td>" + 
  "</tr>" + 
"</table>" + 
"<p><input type='hidden' name='active2' value='no'><input id='a2' type='checkbox' name='active2' value='yes'$active2_chk><label for='a2'> Account aktiv</label></p>" +
"</div>");


document.write("<div id='Acount3' style='display:none'>" +
"<table id='mdns3' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service3' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns3_sel='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns3_sel='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom3_sel='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid3_sel='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit3_sel='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip3_sel='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef3_sel='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r35'>Custom URL : </label></td>" +
    "<td><input id='r35' type='text' name='url3' size='45' maxlength='255' value='$(html "$INADYN_MT_URL3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r31'>Username : </label></td>" +
    "<td><input id='r31' type='text' name='user3' size='45' maxlength='255' value='$(html "$INADYN_MT_USER3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r32'>Passwort : </label></td>" +
    "<td><input id='r32' type='password' name='pass3' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r33'>Alias : </label></td>" +
    "<td><input id='r33' type='text' name='alias3' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r34'>Optionen : </label></td>" + 
    "<td><input id='r34' type='text' name='options3' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS3")'></td>" + 
  "</tr>" + 
"</table>" + 
"<p><input type='hidden' name='active3' value='no'><input id='a3' type='checkbox' name='active3' value='yes'$active3_chk><label for='a3'> Account aktiv</label></p>" +
"</div>");


document.write("<div id='Acount4' style='display:none'>" +
"<table id='mdns4' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service4' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns4_sel='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns4_sel='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom4_sel='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid4_sel='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit4_sel='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip4_sel='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef4_sel='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r45'>Custom URL : </label></td>" +
    "<td><input id='r45' type='text' name='url4' size='45' maxlength='255' value='$(html "$INADYN_MT_URL4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r41'>Username : </label></td>" +
    "<td><input id='r41' type='text' name='user4' size='45' maxlength='255' value='$(html "$INADYN_MT_USER4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r42'>Passwort : </label></td>" +
    "<td><input id='r42' type='password' name='pass4' size='45' maxlength='255' value='$(html "$INADYN_MT_PASS4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r43'>Alias : </label></td>" +
    "<td><input id='r43' type='text' name='alias4' size='45' maxlength='255' value='$(html "$INADYN_MT_ALIAS4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r44'>Optionen : </label></td>" + 
    "<td><input id='r44' type='text' name='options4' size='45' maxlength='255' value='$(html "$INADYN_MT_OPTIONS4")'></td>" + 
  "</tr>" + 
"</table>" + 
"<p><input type='hidden' name='active4' value='no'><input id='a4' type='checkbox' name='active4' value='yes'$active4_chk><label for='a4'> Account aktiv</label></p>" +
"</div>");

</script>
EOF

sec_end
