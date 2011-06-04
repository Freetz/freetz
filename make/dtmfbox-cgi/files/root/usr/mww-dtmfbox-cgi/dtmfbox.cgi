#!/bin/sh
# freetz wrapper cgi
echo "</form>"
echo "<table border='0' cellpadding='0' cellspacing='0'>"
echo "<tr><td>"
. ./dtmfbox.cgi
echo "</td></tr></table>"
echo "<div style='display:none'>"
