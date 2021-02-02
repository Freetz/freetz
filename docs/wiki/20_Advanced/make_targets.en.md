# Targets of Freetz's "make"


```
help                                    Shows docs/wiki/20_Advanced/make_targets.en.md

menuconfig                              Configuration of Freetz
menuconfig-nocache                      Configuration without caching of .in files
menuconfig-single                       Alternative configuration
oldconfig                               Updates existing .config file interactive
olddefconfig                            Updates existing .config file automatically
reuseconfig                             Removes device and toolchain related settings from .config file
allnoconfig                             Sets everything to (n)o
allyesconfig                            Sets everything to (y)es

config-clean-deps                       Deselects everything not mandatory
config-clean-deps-keep-busybox          Deselects all except BusyBox applets
config-clean-deps-modules               Deselects all kernel modules
config-clean-deps-libs                  Deselects all libraries
config-clean-deps-busybox               Deselects all BusyBox applets
config-clean-deps-terminfo              Deselects all terminfos

cacheclean                              Removes small cached files and directories
clean                                   Remove unpacked images and some cache files
dirclean                                Clean sources (except tools and .config)
distclean                               Clean everything except the download directory

$(pkg)-precompiled                      Compiles package/library $(pkg)
$(pkg)-dirclean                         Removes build-directory of $(pkg)
$(pkg)-distclean                        Removes build-directory and all target files of $(pkg)

kernel-menuconfig                       Configuration of selected kernel
kernel-precompiled                      Compiles the selected kernel
kernel-dirclean                         Cleans everything of the selected kernel

tools                                   Builds some tools required by Freetz
tools-dirclean                          Cleans everything of the Freetz tools

uclibc-menuconfig                       Configuration of selected uClibc

firmware-nocompile                      Creates firmware without packages and libraries
mirror                                  Downloads all selected package sources files
release                                 Creates a release file (change .version before)

push-firmware                           Calls tools/push_firmware with images/latest.image
                                        For more options, use tools/push_firmware directly
recover                                 Calls tools/recover-eva with configured firmware
```


