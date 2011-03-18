
sec_begin 'Shutdown'
cat << EOF

<h2>
$(lang de:"Beenden von Packages beim herunterfahren" en:"Stop of packages at shutdown")
$(lang de:" (mit Leerzeichen trennen)" en:" (seperat by spaces)")
</h2>

<p>$(lang de:"Zuerst beenden" en:"Stop at first"): <input type="text" id="shutdown_first" name="shutdown_first" size="50" maxlength="255" value="$(html "$MOD_SHUTDOWN_FIRST")"></p>
<p>$(lang de:"Zuletzt beenden" en:"Stop at last"): <input type="text" id="shutdown_last" name="shutdown_last" size="50" maxlength="255" value="$(html "$MOD_SHUTDOWN_LAST")"></p>
<p>$(lang de:"Nicht beenden" en:"Do not stop"): <input type="text" id="shutdown_ignore" name="shutdown_ignore" size="50" maxlength="255" value="$(html "$MOD_SHUTDOWN_IGNORE")"></p>

EOF
sec_end
