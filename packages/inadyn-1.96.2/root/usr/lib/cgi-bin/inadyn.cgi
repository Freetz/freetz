#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

auto_chk=''; man_chk=''
if [ "$INADYN_ENABLED" = "yes" ]; then auto_chk=' checked'; else man_chk=' checked'; fi

for i in 0 1 2 3 4
do
	set active_chk$i = ''
	set dyndns_sel$i = ''
	set dstatdns_sel$i = ''
	set dcustom_sel$i = ''
	set afraid_sel$i = ''
	set zoneedit_sel$i = ''
	set noip_sel$i = ''
	set userdef_sel$i = ''
	for j in 0 1 2 3 4 5
	do
		set verbose_sel$i$j = ''
	done
done

if [ "$INADYN_ACTIVE0" = "yes" ]; then active_chk0=' checked'; fi
if [ "$INADYN_ACTIVE1" = "yes" ]; then active_chk1=' checked'; fi
if [ "$INADYN_ACTIVE2" = "yes" ]; then active_chk2=' checked'; fi
if [ "$INADYN_ACTIVE3" = "yes" ]; then active_chk3=' checked'; fi
if [ "$INADYN_ACTIVE4" = "yes" ]; then active_chk4=' checked'; fi


case "$INADYN_SERVICE0" in
	dyndns.org) dyndns_sel0=' selected' ;;
	dyndns.org-statdns) dstatdns_sel0=' selected' ;;
	dyndns.org-custom) dcustom_sel0=' selected' ;;
	afraid.org) afraid_sel0=' selected' ;;
	zoneedit.com) zoneedit_sel0=' selected' ;;
	no-ip.com) noip_sel0=' selected' ;;
	benutzerdefiniert) userdef_sel0=' selected' ;;
esac

case "$INADYN_SERVICE1" in
	dyndns.org) dyndns_sel1=' selected' ;;
	dyndns.org-statdns) dstatdns_sel1=' selected' ;;
	dyndns.org-custom) dcustom_sel1=' selected' ;;
	afraid.org) afraid_sel1=' selected' ;;
	zoneedit.com) zoneedit_sel1=' selected' ;;
	no-ip.com) noip_sel1=' selected' ;;
	benutzerdefiniert) userdef_sel1=' selected' ;;
esac

case "$INADYN_SERVICE2" in
	dyndns.org) dyndns_sel2=' selected' ;;
	dyndns.org-statdns) dstatdns_sel2=' selected' ;;
	dyndns.org-custom) dcustom_sel2=' selected' ;;
	afraid.org) afraid_sel2=' selected' ;;
	zoneedit.com) zoneedit_sel2=' selected' ;;
	no-ip.com) noip_sel2=' selected' ;;
	benutzerdefiniert) userdef_sel2=' selected' ;;
esac

case "$INADYN_SERVICE3" in
	dyndns.org) dyndns_sel3=' selected' ;;
	dyndns.org-statdns) dstatdns_sel3=' selected' ;;
	dyndns.org-custom) dcustom_sel3=' selected' ;;
	afraid.org) afraid_sel3=' selected' ;;
	zoneedit.com) zoneedit_sel3=' selected' ;;
	no-ip.com) noip_sel3=' selected' ;;
	benutzerdefiniert) userdef_sel3=' selected' ;;
esac

case "$INADYN_SERVICE4" in
	dyndns.org) dyndns_sel4=' selected' ;;
	dyndns.org-statdns) dstatdns_sel4=' selected' ;;
	dyndns.org-custom) dcustom_sel4=' selected' ;;
	afraid.org) afraid_sel4=' selected' ;;
	zoneedit.com) zoneedit_sel4=' selected' ;;
	no-ip.com) noip_sel4=' selected' ;;
	benutzerdefiniert) userdef_sel4=' selected' ;;
esac

case "$INADYN_VERBOSE0" in
	0) verbose_sel00=' selected' ;;
	1) verbose_sel01=' selected' ;;
	2) verbose_sel02=' selected' ;;
	3) verbose_sel03=' selected' ;;
	4) verbose_sel04=' selected' ;;
	5) verbose_sel05=' selected' ;;
esac

case "$INADYN_VERBOSE1" in
	0) verbose_sel10=' selected' ;;
	1) verbose_sel11=' selected' ;;
	2) verbose_sel12=' selected' ;;
	3) verbose_sel13=' selected' ;;
	4) verbose_sel14=' selected' ;;
	5) verbose_sel15=' selected' ;;
esac

case "$INADYN_VERBOSE2" in
	0) verbose_sel20=' selected' ;;
	1) verbose_sel21=' selected' ;;
	2) verbose_sel22=' selected' ;;
	3) verbose_sel23=' selected' ;;
	4) verbose_sel24=' selected' ;;
	5) verbose_sel25=' selected' ;;
esac

case "$INADYN_VERBOSE3" in
	0) verbose_sel30=' selected' ;;
	1) verbose_sel31=' selected' ;;
	2) verbose_sel32=' selected' ;;
	3) verbose_sel33=' selected' ;;
	4) verbose_sel34=' selected' ;;
	5) verbose_sel35=' selected' ;;
esac

case "$INADYN_VERBOSE4" in
	0) verbose_sel40=' selected' ;;
	1) verbose_sel41=' selected' ;;
	2) verbose_sel42=' selected' ;;
	3) verbose_sel43=' selected' ;;
	4) verbose_sel44=' selected' ;;
	5) verbose_sel45=' selected' ;;
esac

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
function changeverbose(value) {
	document.getElementById("0").style.display = "none";
	document.getElementById("1").style.display = "none";
	document.getElementById("2").style.display = "none";
	document.getElementById("3").style.display = "none";
	document.getElementById("4").style.display = "none";
	document.getElementById("5").style.display = "none";
	
	switch (value) {
		case "0":
			document.getElementById("0").style.display = "block";
			break;
		case "1":
			document.getElementById("1").style.display = "block";
			break;
		case "2":
			document.getElementById("2").style.display = "block";
			break;
		case "3":
			document.getElementById("3").style.display = "block";
			break;
		case "4":
			document.getElementById("4").style.display = "block";
			break;
		case "5":
			document.getElementById("5").style.display = "block";
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
      "<OPTION VALUE1$dyndns_sel0='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns_sel0='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom_sel0='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid_sel0='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit_sel0='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip_sel0='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef_sel0='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r01'>Username : </label></td>" +
    "<td><input id='r01' type='text' name='user0' size='45' maxlength='255' value='$(httpd -e "$INADYN_USER0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r02'>Passwort : </label></td>" +
    "<td><input id='r02' type='password' name='pass0' size='45' maxlength='255' value='$(httpd -e "$INADYN_PASS0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r03'>Alias : </label></td>" +
    "<td><input id='r03' type='text' name='alias0' size='45' maxlength='255' value='$(httpd -e "$INADYN_ALIAS0")'></td>" +
  "</tr><tr>" +
    "<td><label for='r04'>Optionen : </label></td>" +
    "<td><input id='r04' type='text' name='options0' size='45' maxlength='255' value='$(httpd -e "$INADYN_OPTIONS0")'></td>" +
  "</tr><tr>" +
    "<td>Verbose level : </td>" +
    "<td><SELECT NAME='verbose0' onChange='changeverbose(value2)'>" +
      "<OPTION VALUE2$verbose_sel00='0'>0</OPTION>" +
      "<OPTION VALUE2$verbose_sel01='1'>1</OPTION>" +
      "<OPTION VALUE2$verbose_sel02='2'>2</OPTION>" +
      "<OPTION VALUE2$verbose_sel03='3'>3</OPTION>" +
      "<OPTION VALUE2$verbose_sel04='4'>4</OPTION>" +
      "<OPTION VALUE2$verbose_sel05='5'>5</OPTION>" +
    "</SELECT></td>" +
  "</tr>" +
"</table>" + 
"<p><input type='hidden' name='active0' value='no'><input id='a0' type='checkbox' name='active0' value='yes'$active_chk0><label for='a0'> Account aktiv</label></p>" +
"</div>");

document.write("<div id='Acount1' style='display:none'>" +
"<table id='mdns1' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service1' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns_sel1='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns_sel1='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom_sel1='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid_sel1='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit_sel1='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip_sel1='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef_sel1='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r11'>Username : </label></td>" +
    "<td><input id='r11' type='text' name='user1' size='45' maxlength='255' value='$(httpd -e "$INADYN_USER1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r12'>Passwort : </label></td>" +
    "<td><input id='r12' type='password' name='pass1' size='45' maxlength='255' value='$(httpd -e "$INADYN_PASS1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r13'>Alias : </label></td>" +
    "<td><input id='r13' type='text' name='alias1' size='45' maxlength='255' value='$(httpd -e "$INADYN_ALIAS1")'></td>" +
  "</tr><tr>" +
    "<td><label for='r14'>Optionen : </label></td>" +
    "<td><input id='r14' type='text' name='options1' size='45' maxlength='255' value='$(httpd -e "$INADYN_OPTIONS1")'></td>" +
  "</tr><tr>" +
    "<td>Verbose level : </td>" +
    "<td><SELECT NAME='verbose1' onChange='changeverbose(value2)'>" +
      "<OPTION VALUE2$verbose_sel10='0'>0</OPTION>" +
      "<OPTION VALUE2$verbose_sel11='1'>1</OPTION>" +
      "<OPTION VALUE2$verbose_sel12='2'>2</OPTION>" +
      "<OPTION VALUE2$verbose_sel13='3'>3</OPTION>" +
      "<OPTION VALUE2$verbose_sel14='4'>4</OPTION>" +
      "<OPTION VALUE2$verbose_sel15='5'>5</OPTION>" +
    "</SELECT></td>" +
  "</tr>" +
"</table>" + 
"<p><input type='hidden' name='active1' value='no'><input id='a1' type='checkbox' name='active1' value='yes'$active_chk1><label for='a1'> Account aktiv</label></p>" +
"</div>");

document.write("<div id='Acount2' style='display:none'>" +
"<table id='mdns2' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service2' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns_sel2='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns_sel2='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom_sel2='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid_sel2='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit_sel2='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip_sel2='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef_sel2='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r21'>Username : </label></td>" +
    "<td><input id='r21' type='text' name='user2' size='45' maxlength='255' value='$(httpd -e "$INADYN_USER2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r22'>Passwort : </label></td>" +
    "<td><input id='r22' type='password' name='pass2' size='45' maxlength='255' value='$(httpd -e "$INADYN_PASS2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r23'>Alias : </label></td>" +
    "<td><input id='r23' type='text' name='alias2' size='45' maxlength='255' value='$(httpd -e "$INADYN_ALIAS2")'></td>" +
  "</tr><tr>" +
    "<td><label for='r24'>Optionen : </label></td>" +
    "<td><input id='r24' type='text' name='options2' size='45' maxlength='255' value='$(httpd -e "$INADYN_OPTIONS2")'></td>" +
  "</tr><tr>" +
    "<td>Verbose level : </td>" +
    "<td><SELECT NAME='verbose2' onChange='changeverbose(value2)'>" +
      "<OPTION VALUE2$verbose_sel20='0'>0</OPTION>" +
      "<OPTION VALUE2$verbose_sel21='1'>1</OPTION>" +
      "<OPTION VALUE2$verbose_sel22='2'>2</OPTION>" +
      "<OPTION VALUE2$verbose_sel23='3'>3</OPTION>" +
      "<OPTION VALUE2$verbose_sel24='4'>4</OPTION>" +
      "<OPTION VALUE2$verbose_sel25='5'>5</OPTION>" +
    "</SELECT></td>" +
  "</tr>" +
"</table>" + 
"<p><input type='hidden' name='active2' value='no'><input id='a2' type='checkbox' name='active2' value='yes'$active_chk2><label for='a2'> Account aktiv</label></p>" +
"</div>");


document.write("<div id='Acount3' style='display:none'>" +
"<table id='mdns3' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service3' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns_sel3='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns_sel3='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom_sel3='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid_sel3='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit_sel3='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip_sel3='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef_sel3='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r31'>Username : </label></td>" +
    "<td><input id='r31' type='text' name='user3' size='45' maxlength='255' value='$(httpd -e "$INADYN_USER3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r32'>Passwort : </label></td>" +
    "<td><input id='r32' type='password' name='pass3' size='45' maxlength='255' value='$(httpd -e "$INADYN_PASS3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r33'>Alias : </label></td>" +
    "<td><input id='r33' type='text' name='alias3' size='45' maxlength='255' value='$(httpd -e "$INADYN_ALIAS3")'></td>" +
  "</tr><tr>" +
    "<td><label for='r34'>Optionen : </label></td>" +
    "<td><input id='r34' type='text' name='options3' size='45' maxlength='255' value='$(httpd -e "$INADYN_OPTIONS3")'></td>" +
  "</tr><tr>" +
    "<td>Verbose level : </td>" +
    "<td><SELECT NAME='verbose3' onChange='changeverbose(value2)'>" +
      "<OPTION VALUE2$verbose_sel30='0'>0</OPTION>" +
      "<OPTION VALUE2$verbose_sel31='1'>1</OPTION>" +
      "<OPTION VALUE2$verbose_sel32='2'>2</OPTION>" +
      "<OPTION VALUE2$verbose_sel33='3'>3</OPTION>" +
      "<OPTION VALUE2$verbose_sel34='4'>4</OPTION>" +
      "<OPTION VALUE2$verbose_sel35='5'>5</OPTION>" +
    "</SELECT></td>" +
  "</tr>" +
"</table>" + 
"<p><input type='hidden' name='active3' value='no'><input id='a3' type='checkbox' name='active3' value='yes'$active_chk3><label for='a3'> Account aktiv</label></p>" +
"</div>");


document.write("<div id='Acount4' style='display:none'>" +
"<table id='mdns4' style='margin: auto'>" +
  "<tr>" +
    "<td>DNS Service : </td>" +
    "<td><SELECT NAME='service4' onChange='changeservice(value1)'>" +
      "<OPTION VALUE1$dyndns_sel4='0'>dyndns.org</OPTION>" +
      "<OPTION VALUE1$dstatdns_sel4='1'>dyndns.org-statdns</OPTION>" +
      "<OPTION VALUE1$dcustom_sel4='2'>dyndns.org-custom</OPTION>" +
      "<OPTION VALUE1$afraid_sel4='3'>afraid.org</OPTION>" +
      "<OPTION VALUE1$zoneedit_sel4='4'>zoneedit.com</OPTION>" +
      "<OPTION VALUE1$noip_sel4='5'>no-ip.com</OPTION>" +
      "<OPTION VALUE1$userdef_sel4='6'>benutzerdefiniert</OPTION>" +
    "</SELECT></td>" +
  "</tr><tr>" +
    "<td><label for='r41'>Username : </label></td>" +
    "<td><input id='r41' type='text' name='user4' size='45' maxlength='255' value='$(httpd -e "$INADYN_USER4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r42'>Passwort : </label></td>" +
    "<td><input id='r42' type='password' name='pass4' size='45' maxlength='255' value='$(httpd -e "$INADYN_PASS4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r43'>Alias : </label></td>" +
    "<td><input id='r43' type='text' name='alias4' size='45' maxlength='255' value='$(httpd -e "$INADYN_ALIAS4")'></td>" +
  "</tr><tr>" +
    "<td><label for='r44'>Optionen : </label></td>" +
    "<td><input id='r44' type='text' name='options4' size='45' maxlength='255' value='$(httpd -e "$INADYN_OPTIONS4")'></td>" +
  "</tr><tr>" +
    "<td>Verbose level : </td>" +
    "<td><SELECT NAME='verbose4' onChange='changeverbose(value2)'>" +
      "<OPTION VALUE2$verbose_sel40='0'>0</OPTION>" +
      "<OPTION VALUE2$verbose_sel41='1'>1</OPTION>" +
      "<OPTION VALUE2$verbose_sel42='2'>2</OPTION>" +
      "<OPTION VALUE2$verbose_sel43='3'>3</OPTION>" +
      "<OPTION VALUE2$verbose_sel44='4'>4</OPTION>" +
      "<OPTION VALUE2$verbose_sel45='5'>5</OPTION>" +
    "</SELECT></td>" +
  "</tr>" +
"</table>" + 
"<p><input type='hidden' name='active4' value='no'><input id='a4' type='checkbox' name='active4' value='yes'$active_chk4><label for='a4'> Account aktiv</label></p>" +
"</div>");

</script>
EOF

sec_end
