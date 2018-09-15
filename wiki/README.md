# Mirroring of Freetz' Wiki content

Due to the current state of the freetz.org webserver, which works very unstable and suffers from many breakdowns in a short period, I've tried to rescue as many data as possible from the Wiki located there.

It shouldn't be a copyright problem, because all content was published under the URL http://freetz.org/wiki (and some pages linked from there) and the impress page of freetz.org states explicitely, that all content is provided under a CY-BY-SA 2.0 license (see https://creativecommons.org/licenses/by-sa/2.0/ for further information).

The source was named above, the license was mentioned and linked above and there were no further changes.

If you want to read the pages from freetz.wiki.tar.gz locally, you have to unpack the TAR file first. You may browse through the unpacked files with any HTML browser, as long as it supports the "file" protocol for data access or you have to insert the unpacked files into any existing or newly started HTTP server instance.

If you want to serve the files from - e.g. - a BusyBox 'httpd' server applet, you may use the following command to start a new instance on TCP port 8088:

```
busybox httpd -p 8088 -h freetz.org
```

If you want to renew the archive file, you may use the script ```mirror_freetz_wiki```, as long as your system has a GNU wget version 1.19 (or above) installed.
