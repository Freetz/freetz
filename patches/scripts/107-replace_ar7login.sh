[ "$FREETZ_REPLACE_AR7LOGIN" == "y" ] || return 0
echo1 "replacing ar7login by wrapper"

[ ! -f "${FILESYSTEM_MOD_DIR}/sbin/ar7login" ] && echo2 "file not found" && exit 1

echo2 "renaming ar7login"
mv -f \
  "${FILESYSTEM_MOD_DIR}/sbin/ar7login" \
  "${FILESYSTEM_MOD_DIR}/sbin/ar7login.bin"

echo2 "creating ar7login"
cat <<'EOF' > "${FILESYSTEM_MOD_DIR}/sbin/ar7login"
#!/bin/sh

# ar7login wrapper
#
# Author: Alexander Kriegisch (user 'kriegaex' at ip-phone-forum.de)
# update for inetd-compatibility by cuma
#
# Wrap original /sbin/ar7login which was renamed to ar7login.bin in order to
# achieve that telnetd provides normal user/password login instead of AVM web
# password login. Reason: AVM login does not set the user home correctly and
# thus does not execute the user's personal shell profile (~/.profile) as
# expected. For example, user root's normal home in Freetz is /mod/root, but
# ar7login sets it to /, behaving differently than e.g. dropbear.

PATH=/sbin:/bin:/usr/sbin:/usr/bin

if echo " $(pidof telnetd) " | grep -q " $PPID " && \
	grep -q '^root:[^*]' /tmp/shadow 2> /dev/null
then
	# If wrapper was started by telnetd AND root password is defined,
	# proceed with regular user/pw login
	exec login
else
	# Otherwise fall back to web password login
	exec ar7login.bin $@
fi
EOF
chmod +x "${FILESYSTEM_MOD_DIR}/sbin/ar7login"

