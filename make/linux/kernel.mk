KERNEL_SUBVERSION:=iln6
KERNEL_BOARD_REF:=$(KERNEL_REF)
KERNEL_DIR:=$(SOURCE_DIR)/kernel/ref-$(KERNEL_REF)-$(AVM_VERSION)
KERNEL_MAKE_DIR:=$(MAKE_DIR)/linux

KERNEL_BUILD_DIR:=$(KERNEL_DIR)
KERNEL_IMAGE:=linux-$(KERNEL_VERSION)/vmlinux.eva_pad
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_REF)-$(AVM_VERSION).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/Config.$(KERNEL_LAYOUT)-$(KERNEL_REF).$(AVM_VERSION)
KERNEL_BUILD_ROOT_DIR:=$(KERNEL_BUILD_DIR)/linux-$(KERNEL_VERSION)

ifeq ($(KERNEL_REF),4mb_26)
KERNEL_FREETZ_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/.freetz_config
KERNEL_FREETZ_CONFIG_TEMP:=$(KERNEL_MAKE_DIR)/.freetz_config.temp

$(KERNEL_FREETZ_CONFIG_FILE): $(TOPDIR)/.config
	@echo "FREETZ_KERNEL_LAYOUT=$(KERNEL_LAYOUT)" > $(KERNEL_FREETZ_CONFIG_TEMP)
	@diff -q $(KERNEL_FREETZ_CONFIG_TEMP) $(KERNEL_FREETZ_CONFIG_FILE) || \
		cp $(KERNEL_FREETZ_CONFIG_TEMP) $(KERNEL_FREETZ_CONFIG_FILE)
	@rm -f $(KERNEL_FREETZ_CONFIG_TEMP)
endif

# Make sure that a perfectly clean build is performed whenever Freetz package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(KERNEL_DIR)/.unpacked: $(SOURCE_DIR)/kernel/avm-gpl-$(AVM_VERSION)/.unpacked $(KERNEL_FREETZ_CONFIG_FILE) \
				| $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc
	@echo -n "preparing... "
	rm -rf $(KERNEL_DIR)
	mkdir -p $(KERNEL_DIR)
	@KERNEL_SOURCE_PATH=`find $(SOURCE_DIR)/kernel/avm-gpl-$(AVM_VERSION) -maxdepth 6 -wholename "*kernel/linux-2.6.??.?" -type d`; \
	if test -z $$KERNEL_SOURCE_PATH; then \
		$(call ERROR,1,KERNEL_SOURCE_PATH is empty) \
	fi; \
	KERNEL_SOURCE_PATH+="/.."; \
	$(ECHO) Copying $$KERNEL_SOURCE_PATH to $(KERNEL_BUILD_DIR); \
	cp -a $$KERNEL_SOURCE_PATH $(KERNEL_BUILD_DIR)
	@set -e; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR) $$i; \
	done
	#Version specific patches
	@set -e; shopt -s nullglob; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/$(AVM_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR) $$i; \
	done
	@for i in $(KERNEL_LINKING_FILES); do \
		if test -e $(KERNEL_BUILD_ROOT_DIR)/$$i -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}; then \
			$(ECHO) Linking  .../include/linux/$${i##*\/linux_}; \
			ln -sf ../../$$i $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}; \
		fi \
	done
	@if test -e $(KERNEL_BUILD_ROOT_DIR)/drivers/char/avm_net_trace/avm_net_trace.h -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/avm_net_trace.h; then \
			$(ECHO) Linking  .../include/linux/avm_net_trace.h; \
			ln -sf ../../drivers/char/avm_net_trace/avm_net_trace.h \
				$(KERNEL_BUILD_ROOT_DIR)/include/linux/avm_net_trace.h; \
	fi
	@for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		if test -e $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile.26 -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile ; then \
			$(ECHO) Linking  .../$$i/Makefile; \
			ln -sf Makefile.26 $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile; \
		fi \
	done
	@for i in $(KERNEL_DUMMY_DIRS); do \
		if test ! -e $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile ; then \
			$(ECHO) Creating .../$$i/Makefile; \
			mkdir -p $(KERNEL_BUILD_ROOT_DIR)/$$i; \
			test -h $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile && \
				rm $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile; \
			touch $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile; \
		fi \
	done
	@for i in $(KERNEL_OTHER_FILES); do \
		if test ! -e $(KERNEL_BUILD_ROOT_DIR)/$$i ; then \
			$(ECHO) Creating  .../$$i; \
			mkdir -p $(KERNEL_BUILD_ROOT_DIR)/$${i%\/*}; \
			test -h $(KERNEL_BUILD_ROOT_DIR)/$$i && \
				rm $(KERNEL_BUILD_ROOT_DIR)/$$i; \
			touch $(KERNEL_BUILD_ROOT_DIR)/$$i; \
		fi \
	done
	ln -s linux-$(KERNEL_VERSION) $(KERNEL_BUILD_DIR)/linux
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_ROOT_DIR)/.config
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		oldconfig
	touch $@

$(KERNEL_DIR)/.depend_done:  $(KERNEL_DIR)/.configured
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		prepare
	touch $@

$(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.depend_done $(TOOLS_DIR)/lzma2eva
	@echo -n "building kernel image... "
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(notdir $(KERNEL_IMAGE))
	touch -c $@

kernel-force:
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(notdir $(KERNEL_IMAGE))

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	cp $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp $(KERNEL_BUILD_ROOT_DIR)/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_REF)-$(AVM_VERSION).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_REF)-$(AVM_VERSION)
	touch -c $@

$(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	@echo -n "building modules... "
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_BUILD_DIR)" \
		modules
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_BUILD_DIR)" \
		modules_install
	touch $@

$(KERNEL_MODULES_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT)
	rm -rf $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	KERNEL_MODULES_SOURCE_DIR=$(KERNEL_BUILD_DIR)/lib/modules/$(KERNEL_VERSION)/kernel; \
	[ ! -e $$KERNEL_MODULES_SOURCE_DIR ] && \
		KERNEL_MODULES_SOURCE_DIR=$(KERNEL_BUILD_DIR)/lib/modules/$(KERNEL_VERSION)-$(KERNEL_LAYOUT)/kernel; \
	tar -cf - -C $$KERNEL_MODULES_SOURCE_DIR \
		. | tar -xf - -C $(KERNEL_MODULES_DIR)
	touch $@

kernel-pre-echo:
	@echo -n "---> kernel: "

kernel-post-echo:
	@echo "done."

kernel-precompiled: kernel-pre-echo $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY) $(KERNEL_MODULES_DIR)/.modules-$(KERNEL_LAYOUT) kernel-post-echo

kernel-configured: $(KERNEL_DIR)/.depend_done

kernel-modules: $(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT)

kernel-menuconfig: $(KERNEL_DIR)/.configured
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		menuconfig
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-oldconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	$(SUBMAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	$(RM) -r $(KERNEL_DIR)

kernel-distclean: kernel-dirclean
	$(RM) $(KERNEL_TARGET_DIR)/.version-*
	$(RM) $(KERNEL_TARGET_DIR)/System*
	$(RM) $(KERNEL_TARGET_DIR)/kernel-*
	$(RM) -r $(KERNEL_TARGET_DIR)/modules-*

.PHONY: kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig
