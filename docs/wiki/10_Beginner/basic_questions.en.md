# Basic questions

### Good to know

  * Find an entry in menuconfig/kconfig?<br>
    Open menuconfig and then input the ```/``` character to search.
  * Flash an (avm or modified) image by bootloader?<br>
    Run ```tools/push_firmware```, use ```tools/push_firmware -h``` for help.
    Or just ```make push_firmware``` after ```make```.
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
     - If you dont know which module for a specific device is required, attach the device to a Linux PC to check it. Commands: `dmesg`, `lsusb`, `lsmod` etc
     - Make sure the latest source code for your device is available at https://osp.avm.de/ and integrated into Freetz. If not, you need to ask AVM: fritzbox_info@avm.de
     - Now run `make menuconfig` and select your Fritzbox and Fritzos. Then the module needs to be enabled with `make kernel-menuconfig` as "M(odule)", use `/` to search.
     - If you dont want to do that every time, you could upload your changes in `make/linux/configs/freetz/` as a push-request.
     - To copy the file to the image, selected it with ```make menuconfig``` or if not available add its name(s) to `Kernel modules` -> `Own Modules`.
  * Execute files on storages?<br>
    Disabled by default since some time by AVM. To allow,
    select "Drop noexec for (external) storages" patch.
    For internal storages, it is enabled always with Freetz!
  * Execute commands on reboot?<br>
    Put your executable script here: ```/tmp/flash/mod/shutdown```
  * Edit read-only files (or directories)?<br>
    1) Copy the file: ```cp /some/path/to/file /tmp/file```<br>
    2) Mount it: ```mount -o bind /tmp/file /some/path/to/file```
  * Change motd?<br>
    You could put your own \*script\* here: ```/tmp/flash/mod/motd```
    The motd will be generated 1 time at boot. To update it
    regularly, run ```/mod/etc/init.d/rc.mod motd``` eg by cron.
  * Old packages structure in menuconfig?<br>
    To use old packages structure, run ```make menuconfig-single```.
  * How to handle Git?<br>
    Quick start guide for begitners: https://xkcd.com/1597/

