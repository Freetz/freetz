#!/bin/sh


. /usr/lib/libmodcgi.sh

check "$BLUEZ_UTILS_ENABLED" yes:auto "*":man
check "$BLUEZ_UTILS_USE_LINKKEYS" yes:use_linkkeys_yes no:use_linkkeys_no
check "$BLUEZ_UTILS_BNEP_START" yes:bnep_start_yes no:bnep_start_no
check "$BLUEZ_UTILS_RFCOMM_START" yes:rfcomm_start_yes no:rfcomm_start_no
check "$BLUEZ_UTILS_RFCOMMPRG_START" yes:rfcommprg_start_yes no:rfcommprg_start_no
check "$BLUEZ_UTILS_SDPD_START" yes:sdpd_start_yes no:sdpd_start_no
check "$BLUEZ_UTILS_SDPTOOL_START" yes:sdptool_start_yes no:sdptool_start_no
check "$BLUEZ_UTILS_PAND_START" yes:pand_start_yes no:pand_start_no
check "$BLUEZ_UTILS_DUND_START" yes:dund_start_yes no:dund_start_no

sec_begin 'Start type'

cat << EOF
<p>
<input id="e1" type="radio" name="enabled" value="yes"$auto_chk><label for="e1"> Automatic</label>
<input id="e2" type="radio" name="enabled" value="no"$man_chk><label for="e2"> Manual</label>
</p>
EOF


sec_end

sec_begin 'General'

cat << EOF
<p>
<a href="$(href extra bluez-utils bluez-utils-help)">Show Bluez-Utils Help</a>
</p>
<p>
MAC: <input type="text" name="mac" size="20" maxlength="20" value="$(html "$BLUEZ_UTILS_MAC")">
<a href="$(href extra bluez-utils bluez-utils-help)#macaddr">Show MAC</a>
</p>
<p>
PIN: <input type="text" name="pin" size="20" maxlength="20" value="$(html "$BLUEZ_UTILS_PIN")">
</p>
<p>
Use linkkeys-files to save pairing:
<input id="use_linkkeys_1" type="radio" name="use_linkkeys" value="yes"$use_linkkeys_yes_chk><label for="use_linkkeys_1"> yes</label>
<input id="use_linkkeys_2" type="radio" name="use_linkkeys" value="no"$use_linkkeys_no_chk><label for="use_linkkeys_2"> no</label>
<a href="$(href extra bluez-utils bluez-utils-help)#linkkeys"> - Show pairings</a><br>
</p>
EOF
sec_end


sec_begin 'Modules and daemons'
cat << EOF
<p>
Start Sdpd
<input id="sdpd_start_1" type="radio" name="sdpd_start" value="yes"$sdpd_start_yes_chk><label for="sdpd_start_1"> yes</label>
<input id="sdpd_start_2" type="radio" name="sdpd_start" value="no"$sdpd_start_no_chk><label for="sdpd_start_2"> no</label>
</p><p>
sdpd options (leave empty)<input type="text" name="sdpd_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_SDPD_OPTIONS")">
</p>

<p>
Start Bnep
<input id="bnep_start_1" type="radio" name="bnep_start" value="yes"$bnep_start_yes_chk><label for="bnep_start_1"> yes</label>
<input id="bnep_start_2" type="radio" name="bnep_start" value="no"$bnep_start_no_chk><label for="bnep_start_2"> no</label>
</p><p>
bnep options (leave empty)<input type="text" name="bnep_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_BNEP_OPTIONS")">
</p>

<p>
Start Rfcomm
<input id="rfcomm_start_1" type="radio" name="rfcomm_start" value="yes"$rfcomm_start_yes_chk><label for="rfcomm_start_1"> yes</label>
<input id="rfcomm_start_2" type="radio" name="rfcomm_start" value="no"$rfcomm_start_no_chk><label for="rfcomm_start_2"> no</label>
</p><p>
rfcomm options (leave empty)<input type="text" name="rfcomm_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_RFCOMM_OPTIONS")">
</p>


EOF
sec_end

sec_begin 'Programs'
cat << EOF
<p>
Run (once) sdptool
<input id="sdptool_start_1" type="radio" name="sdptool_start" value="yes"$sdptool_start_yes_chk><label for="sdptool_start_1"> yes</label>
<input id="sdptool_start_2" type="radio" name="sdptool_start" value="no"$sdptool_start_no_chk><label for="sdptool_start_2"> no</label>
</p><p>
sdptool options <input type="text" name="sdpdtool_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_SDPDTOOL_OPTIONS")">
</p>

Run (once) rfcomm
<input id="rfcommprg_start_1" type="radio" name="rfcommprg_start" value="yes"$rfcommprg_start_yes_chk><label for="rfcommprg_start_1"> yes</label>
<input id="rfcommprg_start_2" type="radio" name="rfcommprg_start" value="no"$rfcommprg_start_no_chk><label for="rfcommprg_start_2"> no</label>
</p><p>
rfcomm options <input type="text" name="rfcommprg_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_RFCOMMPRG_OPTIONS")">
</p>

EOF
sec_end

sec_begin 'Network Access Point (pand)'
cat << EOF
<p>
Start Pand
<input id="pand_start_1" type="radio" name="pand_start" value="yes"$pand_start_yes_chk><label for="pand_start_1"> yes</label>
<input id="pand_start_2" type="radio" name="pand_start" value="no"$pand_start_no_chk><label for="pand_start_2"> no</label>
</p><p>
sdptool options for usage with pand<input type="text" name="pand_sdpdtool_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_PAND_SDPDTOOL_OPTIONS")">
</p><p>
pand options <input type="text" name="pand_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_PAND_OPTIONS")">
</p>
EOF
sec_end

sec_begin 'Network Access Point (dund)'
cat << EOF
<p>
Start Dund
<input id="dund_start_1" type="radio" name="dund_start" value="yes"$dund_start_yes_chk><label for="dund_start_1"> yes</label>
<input id="dund_start_2" type="radio" name="dund_start" value="no"$dund_start_no_chk><label for="dund_start_2"> no</label>
</p><p>
sdptool options for usage with dund <input type="text" name="dund_sdpdtool_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_DUND_SDPDTOOL_OPTIONS")">
</p><p>
dund options <input type="text" name="dund_options" size="80" maxlength="80" value="$(html "$BLUEZ_UTILS_DUND_OPTIONS")">
</p>
EOF
sec_end
