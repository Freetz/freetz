KERNEL_SUBVERSION:=iln6
KERNEL_BOARD_REF:=$(KERNEL_REF)
KERNEL_DIR:=$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel
KERNEL_MAKE_DIR:=$(MAKE_DIR)/linux
ifeq ($(AVM_VERSION),r7203)
KERNEL_BUILD_DIR_N:=kernel_4mb_26_build
else
KERNEL_BUILD_DIR_N:=kernel_8mb_26_build
endif
KERNEL_BUILD_DIR:=$(KERNEL_DIR)/$(KERNEL_BUILD_DIR_N)
KERNEL_IMAGE:=kernel/linux-2.6.13.1/vmlinux.eva_pad
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_REF)-$(AVM_VERSION).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/Config.$(KERNEL_LAYOUT)-$(KERNEL_REF).$(AVM_VERSION)
KERNEL_LZMA_CFLAGS:=-D__KERNEL__ -Wall -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing \
		   				-fno-common -ffreestanding -falign-functions=4  -falign-labels=4 -falign-loops=4  -falign-jumps=4 \
		   				-fomit-frame-pointer -g -G 0 -mno-abicalls -fno-pic -finline-limit=100000 -mabi=32 -march=mips32 -Wa,-32 \
		   				-Wa,-march=mips32 -Wa,-mips32 -Wa,--trap
KERNEL_LZMA_LIB:=kernel/linux-2.6.13.1/fs/squashfs/lzma_decode.a

ifeq ($(AVM_VERSION),04.33)
KERNEL_SOURCE_PATH:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/base/$(KERNEL_BUILD_DIR_N)
else
KERNEL_SOURCE_PATH:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/$(KERNEL_BUILD_DIR_N)
endif

$(KERNEL_DIR)/.unpacked: $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/.unpacked
	mkdir -p $(KERNEL_DIR)
	cp -a $(KERNEL_SOURCE_PATH) $(KERNEL_BUILD_DIR)
	for i in $(KERNEL_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR)/kernel $$i; \
	done
	#Version specific patches
	for i in $(KERNEL_MAKE_DIR)/patches/$(AVM_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR)/kernel $$i; \
	done
ifneq ($(AVM_VERSION),04.33)
	# Version 04.29/04.30/r4884 source corrections
	for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		ln -sf Makefile.26 $(KERNEL_BUILD_DIR)/$$i; \
	done
	#Correct other symlinks
	cp $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/drivers/usb/misc/usbauth/Makefile.26 \
	    $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/drivers/usb/ahci/Makefile.26
	for i in ar7wdt.h avm_event.h avm_led.h avm_profile.h; do \
		ln -sf ../../drivers/char/avm_new/linux_$$i \
			$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/$$i; \
	done
	ln -sf ../../drivers/char/avm_power/linux_avm_power.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/avm_power.h
	ln -sf ../../drivers/char/ubik2/linux_ubik2_debug.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/ubik2_debug.h	
	ln -sf ../../drivers/char/ubik2/linux_ubik2_interface.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/ubik2_interface.h
	ln -sf ../../drivers/char/ubik2/linux_ubik2_ul.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/ubik2_ul.h
	ln -sf ../../drivers/isdn/capi_oslib/linux_capi_oslib.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/capi_oslib.h	
	ln -sf ../../drivers/isdn/capi_oslib/linux_new_capi.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/new_capi.h	
	ln -sf ../../drivers/net/avm_cpmac/linux_adm_reg.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/adm_reg.h	
	ln -sf ../../drivers/net/avm_cpmac/linux_avm_cpmac.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/avm_cpmac.h	
endif
	ln -s $(KERNEL_BUILD_DIR_N)/kernel/linux-2.6.13.1 $(KERNEL_DIR)/linux 
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/.config
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		oldconfig 
	touch $@
	
$(KERNEL_DIR)/.depend_done:  $(KERNEL_DIR)/.configured
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		prepare
	touch $@

$(KERNEL_BUILD_DIR)/$(KERNEL_LZMA_LIB): $(KERNEL_DIR)/.depend_done $(TOOLS_DIR)/lzma
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/lzma lzma_decode.a CROSS_COMPILE=$(KERNEL_CROSS) \
		USE_CFLAGS="$(KERNEL_LZMA_CFLAGS)"
	cp $(KERNEL_BUILD_DIR)/lzma/lzma_decode.a $@

$(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.depend_done $(KERNEL_BUILD_DIR)/$(KERNEL_LZMA_LIB) $(TOOLS_DIR)/lzma2eva
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$$(basename $(KERNEL_IMAGE))
	touch -c $@

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	cp $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp  $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_REF)-$(AVM_VERSION).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_REF)-$(AVM_VERSION)
	touch -c $@
	
$(KERNEL_DIR)/.modules: $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules
	PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules_install
	touch $@

$(KERNEL_MODULES_DIR)/.modules: $(KERNEL_DIR)/.modules
	rm -rf $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	tar -cf - -C $(KERNEL_BUILD_DIR)/modules \
		--exclude=lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/build \
		--exclude=lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/pcmcia \
		. | tar -xf - -C $(KERNEL_MODULES_DIR)
	touch $@

kernel-precompiled: $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY) $(KERNEL_MODULES_DIR)/.modules

kernel-configured: $(KERNEL_DIR)/.depend_done

kernel-modules: $(KERNEL_DIR)/.modules

kernel-menuconfig: $(KERNEL_DIR)/.unpacked
	[ -f $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/.config ] || cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/.config
		PATH=$(KERNEL_MAKE_PATH):$(PATH) \
		$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		menuconfig
	-cp -f $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-oldconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	rm -f $(KERNEL_BUILD_DIR)/$(KERNEL_LZMA_LIB)
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	rm -rf $(KERNEL_DIR)

.PHONY: kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig
