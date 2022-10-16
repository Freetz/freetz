cgi_begin "$(lang de:"Defragmentiere" en:"Clean up TFFS") ..."
echo -n '<pre>tffs cleanup ... '
echo 'cleanup' > /proc/tffs
echo 'done.</pre>'
back_button mod status
cgi_end
