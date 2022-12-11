#!/bin/sh

. /usr/lib/libmodcgi.sh
[ -r /etc/options.cfg ] && . /etc/options.cfg


sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$UNBOUND_ENABLED" "" "" 0
if [ "$FREETZ_AVM_HAS_DNSCRASH" != "y" ]; then
cgi_print_checkbox_p "wrapper" "$UNBOUND_WRAPPER" "$(lang de:"vor multid starten" en:"start before multid")"
[ "$FREETZ_AVMDAEMON_DISABLE_DNS" != "y" ] && \
  cgi_print_checkbox_p "multid_restart" "$UNBOUND_MULTID_RESTART" "$(lang de:"multid restarten" en:"restart multid")"
fi
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"
cgi_print_textline_p "cmdline" "$UNBOUND_CMDLINE" 55/250 "$(lang de:"Optionale Parameter" en:"Optional parameters"): "
sec_end

if [ "$FREETZ_PACKAGE_UNBOUND_WEBIF_CRON" == "y" ]; then
sec_begin "$(lang de:"Cron" en:"Cron")"
cgi_print_checkbox_p "cron_enabled" "$UNBOUND_CRON_ENABLED" "$(lang de:"root.hints automatisch updaten" en:"Update root.hints automatically")."
echo "$(lang de:"Zeitpunkt des automatischen Updates (folgende Felder sind erforderlich)" en:"Point in time for automatic update (following values are required)")."
cgi_print_textline_p "cron_weekd" "$UNBOUND_CRON_WEEKD" 1/9 "$(lang de:"Wochentag" en:"Day of week") [0-6]: "
cgi_print_textline_p "cron_timeh" "$UNBOUND_CRON_TIMEH" 2/9 "$(lang de:"Stunde" en:"Hour") [0-23]: "
cgi_print_textline_p "cron_timem" "$UNBOUND_CRON_TIMEM" 2/9 "$(lang de:"Minute" en:"Minute") [0-59]: "
sec_end
fi

