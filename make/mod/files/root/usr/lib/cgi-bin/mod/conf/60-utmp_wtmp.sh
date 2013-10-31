[ -r /etc/options.cfg ] && . /etc/options.cfg

sec_begin 'wtmp'

cgi_print_textline_p "path_wtmp" "$MOD_PATH_WTMP" 50/255 \
  "$(lang de:"Pfad f&uuml;r wtmp" en:"Path for wtmp") (default /var/log/): "

sec_end

