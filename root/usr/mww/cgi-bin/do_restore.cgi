#!/usr/bin/haserl -u 200 -U /var/tmp
<%
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin '$(lang de:"Konfiguration wiederherstellen (Restore)" en:"Restore configuration")' 'do_restore'
%>
<h1>$(lang de:"Wiederherstellung (Restore)" en:"Restore configuration")</h1>

<% if [ -n "$FORM_uploadfile_name" ]; then %>
  $(lang de:"Sie haben gerade die Datei" en:"You just uploaded the file") <b><% echo -n $FORM_uploadfile_name %></b>$(lang de:" hochgeladen." en:".")<br>
  $(lang de:"Sie ist unter dem tempor&auml;ren Namen" en:"It is stored on the Fritz!Box under the temporary name") <i><% echo $FORM_uploadfile %></i>$(lang de:" auf der Fritz!Box gespeichert." en:".")<br>
  $(lang de:"Die Dateigr&ouml;&szlig;e betr&auml;gt" en:"The file size is") <% cat $FORM_uploadfile | wc -c %> $(lang de:"Bytes." en:"bytes.")
  </p>
  <b>$(lang de:"Installationsverlauf:" en:"Installation log:")</b>
  <pre><%
  {
    cd /var/tmp
    export BACKUP_DIR='var_flash'
    export DS_BCK_FILE='ds_mod'
    export FREETZ_BCK_FILE='freetz'
    rm -rf $BACKUP_DIR
    echo "$(lang de:"Sicherungsdateien extrahieren" en:"Extracting backup files")..."
    tar xvzf $FORM_uploadfile
    echo "$(lang de:"Konfiguration wiederherstellen" en:"Restoring configuration")..."
    if [ -e "$BACKUP_DIR/$DS_BCK_FILE" ]; then
    	echo "$(lang de:"Alte Sicherungsdatei gefunden" en:"Found old backup file")"
	mv $BACKUP_DIR/$DS_BCK_FILE $BACKUP_DIR/$FREETZ_BCK_FILE
    fi
    if [ ! -e "$BACKUP_DIR/$FREETZ_BCK_FILE" ]; then
       FORM_restart=off
       echo "$(lang de:"FEHLER: Keine passende Sicherungsdatei" en:"ERROR: Not a valid backup file")"
    else
       if [ "$FORM_freetz_only" = "on" ]; then
          echo "cat $BACKUP_DIR/$FREETZ_BCK_FILE > /var/flash/freetz"
          cat $BACKUP_DIR/$FREETZ_BCK_FILE > /var/flash/freetz
       else
          for file in $(ls $BACKUP_DIR); do
            echo "cat $BACKUP_DIR/$file > /var/flash/$file"
            cat $BACKUP_DIR/$file > /var/flash/$file
          done
       fi
      echo "$(lang de:"ERLEDIGT" en:"DONE")"
    fi
    echo "$(lang de:"Sicherungsdateien l&ouml;schen" en:"Removing backup")..."
    rm -rf $BACKUP_DIR
    rm -f $FORM_uploadfile
    echo "$(lang de:"ERLEDIGT" en:"DONE")"
    if [ "$FORM_restart" = "on" ]; then
      echo "$(lang de:"Neustart in 5 Sekunden" en:"Restarting in 5 seconds")..."
      (sleep 5; reboot)&
    fi
  } | html
  %></pre>
<% else %>
  $(lang de:"Sie haben keine Sicherungs-Datei zum Hochladen ausgew&auml;hlt. Der Zustand" en:"You have not selected any backup file to upload. The Fritz!Box's")
  $(lang de:"der Fritz!Box wurde nicht ver&auml;ndert." en:"configuration was not changed.")
<% fi %>

<p>
<% back_button --title="$(lang de:"Zur&uuml;ck zur &Uuml;bersicht" en:"Back to main page")" mod status %>
</p>

<% cgi_end %>
