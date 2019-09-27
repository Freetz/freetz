# Welcome to Freetz-NG

 _____              _            _   _  ____
|  ___| __ ___  ___| |_ ____    | \ | |/ ___|
| |_ | '__/ _ \/ _ \ __|_  /____|  \| | |  _
|  _|| | |  __/  __/ |_ / /_____| |\  | |_| |
|_|  |_|  \___|\___|\__/___|    |_| \_|\____|


This is a fork of Freetz.
All commits not by administrator (svn),
cuma (trac) or fda77 (git) are merged.

### Quick start:
```
  svn co https://svn.boxmatrix.info/freetz-ng/trunk freetz-ng
  cd freetz-ng/
  svn up
  make help
  make menuconfig
  make
  make push-firmware
```

### Unsupported devices (at the moment):
  * Repeater 310, 600 & 1160: No LAN ports, so a recovery is not possible
  * FRITZ!Box 6591: Firmware image is in Intel Unified Image v3 format
  * FRITZ!Box 6591, 7581 & 7582, Inhaus: These don't use supported uClib or glibc

### Known problems (at the moment):
  * Replace kernel does not work for most latest firmware versions
  * Loading build kernel modules may work or do not. You'll notice
  * No download toolchains for firmware versions since FritzOS 7.0

### Good to know:
  * Find an entry in menuconfig/kconfig?
    Open menuconfig and then input the '/' character to search.
  * Flash an (avm or modified) image by bootloader?
    Run "tools/push\_firmware", use "tools/push\_firmware -h" for help.
    Or just "make push-firmware" after "make".
  * Flash with Raspberry?
    Put the created image onto the raspberry. Download the current push\_firmware script:
    "wget 'https://trac.boxmatrix.info/freetz-ng/browser/freetz-ng/trunk/tools/push\_firmware?format=txt' -O push\_firmware"
    Make it executable: "chmod +x push\_firmware". Now run it: "./push\_firmware ..."
  * Why in-memory image format?
    I's no longer needed, as push\_firmware can flash an image itself.
  * Unpack an image?
    Use "tools/fwdu unpack the.image" to extrace the (inner) filesystem.
  * Older modem/DSL driver?
    Unpack the source image file with fwdu. Then copy the needed files
    with directories to a sub directory of the addon/ directory in Freetz.
    Now enable the new addon in a addon/*.pkg file
    The needed files depends on your device. Examples:
     - For 7490, the whole directory "/lib/modules/dsp\_vr9/"
     - For 7590, the whole directory "/lib/modules/dsp\_vr11/"
  * Replace kernel?
    Don't use it - until you know why you need it!!
    You'll never have an kernel as expected by avm. Maybe some patches
    are missing, maybe some options are not selected as avm intended.
  * Execute files on storages?
    Disabled by default since some time by AVM. To allow,
    select "Drop noexec for (external) storages" patch.
    For internal storages, it is enabled always with Freetz!
  * Change motd?
    You could put your own "script" here: "/tmp/flash/mod/motd"
    The motd will be generated 1 time at boot. To update it
    regularly, run "/mod/etc/init.d/rc.mod motd" eg by cron.
  * Old packages structure?
    To use old packages structure in menuconfig, run "make menuconfig-single".
  * I am a git lover, how to clone?
    You could use one of these mirrors:
     - git clone https://gitlab.com/Freetz-NG/freetz-ng.git freetz-ng
     - git clone https://github.com/Freetz-NG/freetz-ng.git freetz-ng
    Git quick start guide for begitners: https://xkcd.com/1597/

