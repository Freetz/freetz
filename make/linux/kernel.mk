KERNEL_SUBVERSION:=iln6
KERNEL_BOARD_REF:=$(KERNEL_REF)
KERNEL_DIR:=$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel
KERNEL_MAKE_DIR:=$(MAKE_DIR)/linux
KERNEL_BUILD_DIR_N:=kernel_8mb_26_build
KERNEL_BUILD_DIR:=$(KERNEL_DIR)/$(KERNEL_BUILD_DIR_N)
KERNEL_IMAGE:=kernel/linux-2.6.13.1/vmlinux.eva_pad
KERNEL_TARGET_DIR:=kernel
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_REF)-$(AVM_VERSION).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/Config.$(KERNEL_REF).$(AVM_VERSION)
KERNEL_MODULES_DIR:=$(KERNEL_TARGET_DIR)/modules-$(KERNEL_REF)-$(AVM_VERSION)


$(KERNEL_DIR)/.unpacked: $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/.unpacked
	mkdir -p $(KERNEL_DIR)
	cp -a $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/$(KERNEL_BUILD_DIR_N) $(KERNEL_BUILD_DIR)
	for i in $(KERNEL_MAKE_DIR)/patches/*.patch; do \
		patch -d $(KERNEL_BUILD_DIR)/kernel -p0 < $$i; \
	done
	# Version specific patches
	#for i in $(KERNEL_MAKE_DIR)/patches/$(AVM_VERSION)/*.patch; do \
	#	patch -d $(KERNEL_BUILD_DIR)/kernel -p0 < $$i; \
	#done

	# Version 04.29/04.30 source corrections
	for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		ln -sf Makefile.26 $(KERNEL_BUILD_DIR)/$$i; \
	done
	# Correct other symlinks
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
	ln -sf ../../drivers/net/avm_cpmac/linux_adm_reg.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/adm_reg.h	
	ln -sf ../../drivers/net/avm_cpmac/linux_avm_cpmac.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/include/linux/avm_cpmac.h	
	ln -s $(KERNEL_BUILD_DIR_N)/kernel/linux-2.6.13.1 $(KERNEL_DIR)/linux 
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/.config
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		oldconfig
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		prepare
	touch $@

$(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.configured $(TOOLS_DIR)/lzma $(TOOLS_DIR)/lzma2eva
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH=$(KERNEL_ARCH) \
		kernel/linux-2.6.13.1/fs/squashfs/lzma_decode.a
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$$(basename $(KERNEL_IMAGE))
	touch -c $@

$(KERNEL_DIR)/.modules: $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules_install
	touch $@

kernel-precompiled: $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_DIR)/.modules
	cp $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	rm -rf $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	tar -cf - -C $(KERNEL_BUILD_DIR)/modules \
		--exclude=lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/build \
		--exclude=lib/modules/2.6.13.1-$(KERNEL_LAYOUT)/pcmcia \
		. | tar -xf - -C $(KERNEL_MODULES_DIR)
	cp  $(KERNEL_BUILD_DIR)/kernel/linux-2.6.13.1/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_REF)-$(AVM_VERSION).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_REF)-$(AVM_VERSION)

kernel-configured: $(KERNEL_DIR)/.configured

kernel-modules: $(KERNEL_DIR)/.modules

kernel-menuconfig: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/Config.$(KERNEL_BOARD_REF)
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		menuconfig

	cp $(KERNEL_BUILD_DIR)/Config.$(KERNEL_BOARD_REF) $(KERNEL_CONFIG_FILE)

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	rm -rf $(KERNEL_DIR)

.PHONY: kernel-configured kernel-modules kernel-menuconfig
