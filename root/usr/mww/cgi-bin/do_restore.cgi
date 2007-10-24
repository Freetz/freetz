#!/usr/bin/haserl -u 200 -U /var/tmp
<?
PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh
cgi_begin 'Konfiguration wiederherstellen (Restore)' 'do_restore'
?>
<h1>Wiederherstellung (Restore)</h1>

<? if test -n "$FORM_uploadfile"; then ?>
  Sie haben gerade die Datei <b><? echo -n $FORM_uploadfile_name ?></b> hochgeladen.<br>
  Sie ist unter dem temporären Namen <i><? echo $FORM_uploadfile ?></i> auf der Fritz!Box gespeichert.<br>
  Die Dateigröße beträgt <? cat $FORM_uploadfile | wc -c ?> Bytes.</p>
  <b>Installationsverlauf:</b>
  <pre><?
    cd /var/tmp
    export BACKUP_DIR='var_flash'
    rm -rf $BACKUP_DIR
    echo "Extracting backup files..."
    tar xvzf $FORM_uploadfile
    echo "Restoring configuration..."
    if [ "$FORM_dsmod_only" = "on" ]; then
      echo "cat $BACKUP_DIR/ds_mod > /var/flash/ds_mod"
      cat $BACKUP_DIR/ds_mod > /var/flash/ds_mod
    else
      for file in $(ls $BACKUP_DIR); do
        echo "cat $BACKUP_DIR/$file > /var/flash/$file"
        cat $BACKUP_DIR/$file > /var/flash/$file
      done
    fi
    echo "done"
    echo "Removing backup..."
    rm -rf $BACKUP_DIR
      rm -f $FORM_uploadfile
    echo "done"
    if [ "$FORM_restart" = "on" ]; then
      echo "Restarting in 5 seconds..."
      (sleep 5; reboot)&
     fi
  ?></pre>
<? else ?>
  Sie haben keine Sicherungs-Datei zum Hochladen ausgewählt. Der Zustand
  der Fritz!Box wurde nicht verändert.
<? fi ?>

<p>
<form action="/cgi-bin/status.cgi" method=GET>
  <input type=submit value="Zurück zur Übersicht">
</form><p>

<? cgi_end ?>
