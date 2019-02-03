cgi_begin 'linux_fs_start ...'
echo '<pre>Toggling ...'

NEXT="$(sed -n 's/^linux_fs_start[ \t]*//p' /proc/sys/urlader/environment)"
[ -z "$NEXT" ] && NEXT=0
echo "old value -> $NEXT"

TOGGLE="$(( ($NEXT+1) %2 ))"
echo "new value -> $TOGGLE"

echo "linux_fs_start $TOGGLE" > /proc/sys/urlader/environment

TEST="$(sed -n 's/^linux_fs_start[ \t]*//p' /proc/sys/urlader/environment)"
[ "$TEST" != "$TOGGLE" ] && echo "failed." || echo "done."

echo '</pre>'
back_button mod system
cgi_end
