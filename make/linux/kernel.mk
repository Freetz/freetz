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
KERNEL_IMAGE:=kernel/linux-$(KERNEL_VERSION)/vmlinux.eva_pad
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_REF)-$(AVM_VERSION).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/Config.$(KERNEL_LAYOUT)-$(KERNEL_REF).$(AVM_VERSION)

KERNEL_SOURCE_PATH__04.29:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/$(KERNEL_BUILD_DIR_N)
KERNEL_SOURCE_PATH__04.33:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/base/$(KERNEL_BUILD_DIR_N)
KERNEL_SOURCE_PATH__04.40:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/base/$(KERNEL_BUILD_DIR_N)
KERNEL_SOURCE_PATH__55.04:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/kernel_arm926_debug_build
KERNEL_SOURCE_PATH__r4884:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/$(KERNEL_BUILD_DIR_N)
KERNEL_SOURCE_PATH__r7203:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/$(KERNEL_BUILD_DIR_N)
KERNEL_SOURCE_PATH__r8508:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/open-source-package/kernel/$(KERNEL_BUILD_DIR_N)

KERNEL_SOURCE_PATH:=$(KERNEL_SOURCE_PATH__$(AVM_VERSION))

ifeq ($(KERNEL_REF),4mb_26)
KERNEL_DS_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/.ds_config
KERNEL_DS_CONFIG_TEMP:=$(KERNEL_MAKE_DIR)/.ds_config.temp

$(KERNEL_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_KERNEL_LAYOUT=$(KERNEL_LAYOUT)" > $(KERNEL_DS_CONFIG_TEMP)
	@diff -q $(KERNEL_DS_CONFIG_TEMP) $(KERNEL_DS_CONFIG_FILE) || \
		cp $(KERNEL_DS_CONFIG_TEMP) $(KERNEL_DS_CONFIG_FILE)
	@rm -f $(KERNEL_DS_CONFIG_TEMP)
endif

# Make sure that a perfectly clean build is performed whenever DS-Mod package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(KERNEL_DIR)/.unpacked: $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/.unpacked $(KERNEL_DS_CONFIG_FILE)
	rm -rf $(KERNEL_DIR)
	mkdir -p $(KERNEL_DIR)
	cp -a $(KERNEL_SOURCE_PATH) $(KERNEL_BUILD_DIR)
	for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR)/kernel $$i; \
	done
	#Version specific patches
	shopt -s nullglob; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/$(AVM_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR)/kernel $$i; \
	done
ifneq ($(AVM_VERSION),04.33)
 ifneq ($(AVM_VERSION),04.40)
  ifneq ($(AVM_VERSION),55.04)
	# Version 04.29/04.30/r4884 source corrections
	for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		ln -sf Makefile.26 $(KERNEL_BUILD_DIR)/$$i; \
	done
	#Correct other symlinks
	cp $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/drivers/usb/misc/usbauth/Makefile.26 \
	    $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/drivers/usb/ahci/Makefile.26
	for i in ar7wdt.h avm_event.h avm_led.h avm_profile.h; do \
		ln -sf ../../drivers/char/avm_new/linux_$$i \
			$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/$$i; \
	done
	ln -sf ../../drivers/char/avm_power/linux_avm_power.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/avm_power.h
	ln -sf ../../drivers/char/ubik2/linux_ubik2_debug.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/ubik2_debug.h
	ln -sf ../../drivers/char/ubik2/linux_ubik2_interface.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/ubik2_interface.h
	ln -sf ../../drivers/char/ubik2/linux_ubik2_ul.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/ubik2_ul.h
	ln -sf ../../drivers/isdn/capi_oslib/linux_capi_oslib.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/capi_oslib.h
	ln -sf ../../drivers/isdn/capi_oslib/linux_new_capi.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/new_capi.h
	ln -sf ../../drivers/net/avm_cpmac/linux_adm_reg.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/adm_reg.h
	ln -sf ../../drivers/net/avm_cpmac/linux_avm_cpmac.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/include/linux/avm_cpmac.h
  endif
 endif
endif

	ln -s $(KERNEL_BUILD_DIR_N)/kernel/linux-$(KERNEL_VERSION) $(KERNEL_DIR)/linux
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/.config
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		oldconfig
	touch $@

$(KERNEL_DIR)/.depend_done:  $(KERNEL_DIR)/.configured
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		prepare
	touch $@

$(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.depend_done $(TOOLS_DIR)/lzma2eva
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(notdir $(KERNEL_IMAGE))
	touch -c $@

kernel-force:
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(notdir $(KERNEL_IMAGE))

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	cp $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp  $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_REF)-$(AVM_VERSION).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_REF)-$(AVM_VERSION)
	touch -c $@

$(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules
	PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules_install
	touch $@

$(KERNEL_MODULES_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT)
	rm -rf $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	tar -cf - -C $(KERNEL_BUILD_DIR)/modules \
		--exclude=lib/modules/$(KERNEL_VERSION)-$(KERNEL_LAYOUT)/build \
		--exclude=lib/modules/$(KERNEL_VERSION)-$(KERNEL_LAYOUT)/pcmcia \
		. | tar -xf - -C $(KERNEL_MODULES_DIR)
	touch $@

kernel-precompiled: $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY) $(KERNEL_MODULES_DIR)/.modules-$(KERNEL_LAYOUT)

kernel-configured: $(KERNEL_DIR)/.depend_done

kernel-modules: $(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT)

kernel-menuconfig: $(KERNEL_DIR)/.unpacked
	[ -f $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/.config ] || cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/.config
		PATH=$(KERNEL_MAKE_PATH):$(PATH) \
		$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		menuconfig
	-cp -f $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-oldconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	rm -rf $(KERNEL_DIR)

.PHONY: kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig
