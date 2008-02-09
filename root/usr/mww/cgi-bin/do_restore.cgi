#!/usr/bin/haserl -u 200 -U /var/tmp
<?
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin '$(lang de:"Konfiguration wiederherstellen (Restore)" en:"Restore configuration")' 'do_restore'
?>
<h1>$(lang de:"Wiederherstellung (Restore)" en:"Restore configuration")</h1>

<? if test -n "$FORM_uploadfile"; then ?>
  $(lang de:"Sie haben gerade die Datei" en:"You just uploaded the file") <b><? echo -n $FORM_uploadfile_name ?></b>$(lang de:" hochgeladen." en:".")<br>
  $(lang de:"Sie ist unter dem temporären Namen" en:"It is stored on the Fritz!Box under the temporary name") <i><? echo $FORM_uploadfile ?></i>$(lang de:" auf der Fritz!Box gespeichert." en:".")<br>
  $(lang de:"Die Dateigröße beträgt" en:"The file size is") <? cat $FORM_uploadfile | wc -c ?> $(lang de:"Bytes." en:"bytes.")
  </p>
  <b>$(lang de:"Installationsverlauf:" en:"Installation log:")</b>
  <pre><?
    cd /var/tmp
    export BACKUP_DIR='var_flash'
    rm -rf $BACKUP_DIR
    echo "$(lang de:"Sicherungsdateien extrahieren" en:"Extracting backup files")..."
    tar xvzf $FORM_uploadfile
    echo "$(lang de:"Konfiguration wiederherstellen" en:"Restoring configuration")..."
    if [ "$FORM_freetz_only" = "on" ]; then
      echo "cat $BACKUP_DIR/ds_mod > /var/flash/ds_mod"
      cat $BACKUP_DIR/ds_mod > /var/flash/ds_mod
    else
      for file in $(ls $BACKUP_DIR); do
        echo "cat $BACKUP_DIR/$file > /var/flash/$file"
        cat $BACKUP_DIR/$file > /var/flash/$file
      done
    fi
    echo "$(lang de:"ERLEDIGT" en:"DONE")"
    echo "$(lang de:"Sicherungsdateien löschen" en:"Removing backup")..."
    rm -rf $BACKUP_DIR
      rm -f $FORM_uploadfile
    echo "$(lang de:"ERLEDIGT" en:"DONE")"
    if [ "$FORM_restart" = "on" ]; then
      echo "$(lang de:"Neustart in 5 Sekunden" en:"Restarting in 5 seconds")..."
      (sleep 5; reboot)&
     fi
  ?></pre>
<? else ?>
  $(lang de:"Sie haben keine Sicherungs-Datei zum Hochladen ausgewählt. Der Zustand" en:"You have not selected any backup file to upload. The Fritz!Box's")
  $(lang de:"der Fritz!Box wurde nicht verändert." en:"configuration was not changed.")
<? fi ?>

<p>
<form action="/cgi-bin/status.cgi" method=GET>
  <input type=submit value="$(lang de:"Zurück zur Übersicht" en:"Back to main page")">
</form><p>

<? cgi_end ?>
