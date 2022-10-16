# validate login, renew "timer"
checklogin() {
SENDSID=""
SID="$(echo "$HTTP_COOKIE" | sed -n "s%.*SID=\([^\; ]*\).*%\1%p")"
local lastacc=$(( 1 + $MOD_HTTPD_SESSIONTIMEOUT ))
local idfile="/tmp/$SID.webcfg"
[ -e $idfile ] && lastacc=$(( $(date +%s) - $(date -r $idfile +%s 2>/dev/null) ))
if [ -z "$SID" -o $lastacc -gt $MOD_HTTPD_SESSIONTIMEOUT ]; then
    isauth=0;
    [ -n "$SID" -a -e $idfile ] && rm $idfile
    SENDSID="$(echo -n "$(date +%s)" | md5sum | sed 's/[ ]*-//')"
    return 1;
else
    touch $idfile
    isauth=1
fi
return 0
}
