#!/bin/sh
# Preliminary helper for switching skins
# "skin.cgi?name=foo": select skin "foo"
# "skin.cgi?reset=1": reset to default

SKIN_DIR=/usr/share/skin
CR=$'\r'

invalid_skin() {
    local name=$1
    cat << EOF
Content-Type: text/html${CR}
${CR}
<html><body>
<h1>Error: '$name' is not a valid skin.</h1>
<ul>
EOF
    local skin
    for skin in $(ls "$SKIN_DIR"); do
	echo "<li><a href="?name=$skin">$skin</a></li>"
    done
    echo "</ul></body></html>"
    exit
}

default_skin=legacy
set_skin() {
    local name=$1
    cookie_redir "skin=$name; Path=/; Max-Age=$((20*365*24*3600))"
}

reset_skin() {
    cookie_redir "skin=${default_skin}; Path=/; Max-Age=0"
}

redir_target=/
cookie_redir() {
    cat << EOF
Status: 302 Found${CR}
Set-Cookie: $1${CR}
Location: ${redir_target}${CR}
${CR}
EOF
    exit
}

eval "$(modcgi name:reset skin)"
[ -n "${SKIN_RESET+1}" ] && reset_skin
case $SKIN_NAME in
    ""|*[^A-Za-z0-9_]*) invalid_skin "$SKIN_NAME" ;;
    *) [ ! -d "$SKIN_DIR/$SKIN_NAME" ] && invalid_skin "$SKIN_NAME" ;;
esac

set_skin "$SKIN_NAME"
