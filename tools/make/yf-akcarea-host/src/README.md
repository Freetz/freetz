This folder contains some utilities to replace/recreate missing parts from AVM's open-source package.

AVM invented a mechanism to initialize some internal structures at kernel startup from a model-specific part and there seems to be
no way to get these sources from vendor - at least an explicit demand to provide them was more or less ignored. The sources pointed
out in their answer didn't contain any changes regarding these missing parts.

So one of the possible solutions was reverse engineering the content of this area and the files provided in this folder are a first
approach to take this way.

You can find further information in an IPPF thread (but it's in German only):

http://www.ip-phone-forum.de/showthread.php?t=287995

If you want to compile the contained sources for a specific model, you have to provide a symlink named "linux" to the root of the
correct kernel sources. The files "include/uapi/linux/avm_kernel_config.h" and the whole directory "scripts/dtc/libfdt" (from the
OpenFirmware device-tree compiler) are the parts needed from current kernel sources.