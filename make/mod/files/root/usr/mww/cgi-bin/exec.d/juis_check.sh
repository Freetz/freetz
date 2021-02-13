cgi_begin 'juis_check ...'
echo '<pre>'
echo 'Please wait ...'
echo

juis | html

echo
echo "done."
echo '</pre>'
back_button mod system
cgi_end

