ifeq ($(AVM_VERSION),04.01)
KERNEL_VERSION:=920
KERNEL_SOURCE:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/kernel-src-$(KERNEL_VERSION).tar.gz
endif

KERNEL_SUBVERSION:=iln6
KERNEL_BOARD_REF:=$(KERNEL_REF)
KERNEL_DIR:=$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel
KERNEL_MAKE_DIR:=$(MAKE_DIR)/linux
KERNEL_BUILD_DIR_N:=kernel_ohio-8mb_build
KERNEL_BUILD_DIR:=$(KERNEL_DIR)/$(KERNEL_BUILD_DIR_N)
KERNEL_IMAGE:=kernel/linux-2.4.17_mvl21/ram_zimage.bin
KERNEL_TARGET_DIR:=kernel
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_REF)-$(AVM_VERSION).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/Config.$(KERNEL_REF).$(AVM_VERSION)
KERNEL_MODULES_DIR:=$(KERNEL_TARGET_DIR)/modules-$(KERNEL_REF)-$(AVM_VERSION)


$(KERNEL_DIR)/.unpacked: $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/.unpacked
	mkdir -p $(KERNEL_DIR)
ifeq ($(AVM_VERSION),04.01)
	tar -C $(KERNEL_DIR) $(VERBOSE) -xzf $(KERNEL_SOURCE)
else
	cp -a $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/fritzbox_opensrc/$(KERNEL_BUILD_DIR_N) $(KERNEL_BUILD_DIR)
endif
	for i in $(KERNEL_MAKE_DIR)/patches/$(AVM_VERSION)/*.patch; do \
		patch -d $(KERNEL_BUILD_DIR)/kernel -p0 < $$i; \
	done
ifeq ($(AVM_VERSION),04.01)
	# Version 04.01 source corrections
	echo -e "kernel=$(KERNEL_VERSION)" > $(KERNEL_DIR)/version
	echo -e "produkt=Fritz_Box_All" >> $(KERNEL_DIR)/version
	for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		[ -d `dirname $(KERNEL_BUILD_DIR)/$$i` ] || \
			mkdir -p `dirname $(KERNEL_BUILD_DIR)/$$i`; \
		echo -e "# dummy Makefile\ninclude $$\c" > $(KERNEL_BUILD_DIR)/$$i; \
		echo -e "(TOPDIR)/Rules.make" >> $(KERNEL_BUILD_DIR)/$$i; \
	done
	mkdir -p $(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/drivers/isdn/fcclassic/stack/src/utils
	mkdir -p $(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/include/asm-mips/avalanche/generic/hal_modules
endif
ifeq ($(AVM_VERSION),04.06)
	# Version 04.06 source corrections
	for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		ln -sf Makefile.24 $(KERNEL_BUILD_DIR)/$$i; \
	done
	# Correct other symlinks
	for i in ar7wdt.h avm_event.h avm_led.h avm_profile.h; do \
		ln -sf ../../drivers/char/avm_new/linux_$$i \
			$(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/include/linux/$$i; \
	done
	ln -sf ../../drivers/char/avm_power/linux_avm_power.h \
		$(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/include/linux/avm_power.h
	rm -f $(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/drivers/atm/dsl_hal_export.c
	ln -fs sangam_atm/dsl_hal_export.c $(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/drivers/atm/dsl_hal_export.c
endif
	ln -s $(KERNEL_BUILD_DIR_N)/kernel/linux-2.4.17_mvl21 $(KERNEL_DIR)/linux
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/Config.$(KERNEL_BOARD_REF)
ifeq ($(AVM_VERSION),04.01)
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		oldconfig depend
else
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		oldconfig depend
endif
	touch $@

$(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.configured $(TOOLS_DIR)/lzma
ifeq ($(AVM_VERSION),04.01)
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		create_kernel
else
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		kernel/linux-2.4.17_mvl21/fs/squashfs/lzma_decode.a
	export PATH=$(KERNEL_MAKE_PATH):$(PATH); \
	$(MAKE) -C $(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21 \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ram_zimage_pad
endif

$(KERNEL_DIR)/.modules: $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
ifeq ($(AVM_VERSION),04.01)
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		MODLIB="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/lib/modules/2.4.17_mvl21-malta-mips_fp_le" \
		modules
else
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		MODLIB="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/lib/modules/2.4.17_mvl21-malta-mips_fp_le" \
		modules
endif
	touch $@

kernel-precompiled: $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) \
                    $(KERNEL_DIR)/.modules \
                    $(SOURCE_DIR)/depmod.pl
	cp $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	mkdir -p $(KERNEL_MODULES_DIR)
	tar -cf - -C $(KERNEL_BUILD_DIR)/modules \
		--exclude=lib/modules/2.4.17_mvl21-malta-mips_fp_le/build \
		--exclude=lib/modules/2.4.17_mvl21-malta-mips_fp_le/pcmcia \
		--exclude=lib/modules/2.4.17_mvl21-malta-mips_fp_le/kernel/drivers/bluetooth \
		--exclude=lib/modules/2.4.17_mvl21-malta-mips_fp_le/kernel/net/bluetooth \
		. | tar -xf - -C $(KERNEL_MODULES_DIR)
	$(SOURCE_DIR)/depmod.pl -b $(KERNEL_MODULES_DIR)/lib/modules/2.4.17_mvl21-malta-mips_fp_le \
		-F $(KERNEL_BUILD_DIR)/kernel/linux-2.4.17_mvl21/System.map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_REF)-$(AVM_VERSION)

kernel-configured: $(KERNEL_DIR)/.configured

kernel-modules: $(KERNEL_DIR)/.modules

kernel-menuconfig: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_DIR)/Config.$(KERNEL_BOARD_REF)
ifeq ($(AVM_VERSION),04.01)
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		menuconfig
else
	$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		menuconfig
endif
	cp $(KERNEL_BUILD_DIR)/Config.$(KERNEL_BOARD_REF) $(KERNEL_CONFIG_FILE)

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	-$(MAKE) -C $(KERNEL_BUILD_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		BOARD_REF="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	rm -rf $(KERNEL_DIR)

.PHONY: kernel-configured kernel-modules kernel-menuconfig
