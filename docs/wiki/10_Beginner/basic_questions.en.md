# Basic questions

### Good to know

  * Find an entry in menuconfig/kconfig?<br>
    Open menuconfig and then input the ```/``` character to search.
  * Flash an (avm or modified) image by bootloader?<br>
    Run ```tools/push_firmware```, use ```tools/push_firmware -h``` for help.
    Or just ```make push-firmware``` after ```make```.
  * Flash with Raspberry?<br>
    Put the created image onto the raspberry. Download the current push\_firmware script:
    ```wget https://raw.githubusercontent.com/Freetz-NG/freetz-ng/master/tools/push_firmware```
    Make it executable: ```chmod +x push_firmware```. Now run it: ```./push_firmware ...```
  * Why in-memory image format?<br>
    It's no longer needed, as push\_firmware can flash an image itself.
  * Unpack an image?<br>
    Use ```tools/fwdu unpack the.image``` to extrace the (inner) filesystem.
  * Older modem/DSL driver?<br>
    Unpack the source image file with fwdu. Then copy the needed files
    with directories to a sub directory of the ```addon/``` directory in Freetz.
    Now enable the new addon in a ```addon/*.pkg``` file
    The needed files depends on your device. Examples:
     - For 7490, the whole directory ```/lib/modules/dsp_vr9/```
     - For 7590, the whole directory ```/lib/modules/dsp_vr11/```
  * Replace kernel?<br>
    Don't use it - until you know why you need it!
    You'll never have an kernel as expected by avm. Maybe some patches
    are missing, maybe some options are not selected as avm intended.
  * Build kernel modules?<br>
    Make sure the latest source code for your device is available at
    http://osp.avm.de/ and integrated into Freetz. The source code for
    the flag ship model of your series (xx90) should be also available
    to create a "delta" patch. If not, ask AVM: fritzbox_info@avm.de
    The module needs to be enabled with ```make kernel-menuconfig```
    as "M(odule)" and selected with ```make menuconfig```.
  * Execute files on storages?<br>
    Disabled by default since some time by AVM. To allow,
    select "Drop noexec for (external) storages" patch.
    For internal storages, it is enabled always with Freetz!
  * Execute commands on reboot?<br>
    Put your executable script here: ```/tmp/flash/mod/shutdown```.
  * Change motd?<br>
    You could put your own \*script\* here: ```/tmp/flash/mod/motd```
    The motd will be generated 1 time at boot. To update it
    regularly, run ```/mod/etc/init.d/rc.mod motd``` eg by cron.
  * Old packages structure in menuconfig?<br>
    To use old packages structure, run ```make menuconfig-single```.
  * How to handle Git?<br>
    Quick start guide for begitners: https://xkcd.com/1597/

