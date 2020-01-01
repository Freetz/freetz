# CA-bundle 2020-01-01

Das CA-bundle ist ein Paket von root CA (Certificate Authority) Zertifikaten.
<br>
 * Damit kann die Glaubwürdigkeiten von HTTPS Zertifikaten gebpüft werden.
 * Als Benutzer ```root``` nutzen die Programme ```wget``` und ```curl``` diese Zertifikate automatisch.
 * Anderen Benutzer oder Programmen muss die Datei ```/mod/etc/ssl/certs/ca-bundle.crt``` bekannt gemacht werden.

