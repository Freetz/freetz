space:=$(empty) $(empty)
AVM_SOURCE:=$(strip $(subst ",, $(subst $(space),\ ,$(FREETZ_DL_KERNEL_SOURCE))))

AVM_UNPACK__INT_.gz:=z
AVM_UNPACK__INT_.bz2:=j

KERNEL_SUBVERSION:=iln6
KERNEL_BOARD_REF:=$(KERNEL_REF)
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
KERNEL_BUILD_ROOT_DIR:=$(KERNEL_BUILD_DIR)/kernel/linux-$(KERNEL_VERSION)

ifeq ($(KERNEL_REF),4mb_26)
KERNEL_FREETZ_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/.freetz_config
KERNEL_FREETZ_CONFIG_TEMP:=$(KERNEL_MAKE_DIR)/.freetz_config.temp

$(KERNEL_FREETZ_CONFIG_FILE): $(TOPDIR)/.config
	@echo "FREETZ_KERNEL_LAYOUT=$(KERNEL_LAYOUT)" > $(KERNEL_FREETZ_CONFIG_TEMP)
	@diff -q $(KERNEL_FREETZ_CONFIG_TEMP) $(KERNEL_FREETZ_CONFIG_FILE) || \
		cp $(KERNEL_FREETZ_CONFIG_TEMP) $(KERNEL_FREETZ_CONFIG_FILE)
	@rm -f $(KERNEL_FREETZ_CONFIG_TEMP)
endif

$(DL_FW_DIR)/$(AVM_SOURCE): | $(DL_FW_DIR)
	$(DL_TOOL) $(DL_FW_DIR) .config $(FREETZ_DL_KERNEL_SOURCE) $(FREETZ_DL_KERNEL_SITE) $(FREETZ_DL_KERNEL_SOURCE_MD5)

# Make sure that a perfectly clean build is performed whenever Freetz package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
$(KERNEL_DIR)/.unpacked: $(DL_FW_DIR)/$(AVM_SOURCE) $(KERNEL_FREETZ_CONFIG_FILE) \
				| $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc
	$(RM) -r $(KERNEL_DIR)
	$(RM) -r $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)
	mkdir -p $(KERNEL_BUILD_DIR)/kernel
	@echo -n Checking Kernel image structure ...; \
	KERNEL_SOURCE_CONTENT=` \
		tar \
			-t$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
			-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE)| \
		grep -e '^.*\/\(GPL-\(release_\|\)kernel\.tar\.gz\|linux-2\.6\...\..\/\)$$'| \
		head -n 1`; \
		echo done; \
		echo -n Decompressing kernel source files ...; \
	if [ ! -z $$(echo "$$KERNEL_SOURCE_CONTENT"|grep -e '.*\/GPL-\(release_\|\)kernel\.tar\.gz') ]; then \
		tar	-O $(VERBOSE) \
			-x$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
			-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
			--wildcards "*/$${KERNEL_SOURCE_CONTENT##*/}" | \
		tar	-C $(KERNEL_BUILD_DIR)/kernel $(VERBOSE) \
			-xz \
			--transform="s|^.*\(linux-2\.6\...\..\/\)|\1|g" --show-transformed; \
	elif [ -z "$${KERNEL_SOURCE_CONTENT}" ]; then \
		echo error: KERNEL_SOURCE_CONTENT is empty; exit 1; \
	else \
		tar	-C $(KERNEL_BUILD_DIR)/kernel $(VERBOSE) \
			-x$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
			-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
			--transform="s|^.*\(linux-2\.6\...\..\/\)|\1|g" --show-transformed \
			"$$KERNEL_SOURCE_CONTENT"; \
	fi
	@echo done
	@if [ ! -d $(KERNEL_BUILD_ROOT_DIR) ]; then \
		echo error: KERNEL_BUILD_ROOT_DIR has wrong structure; exit 1; \
	fi
	@set -e; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR)/kernel $$i; \
	done
	#Version specific patches
	@set -e; shopt -s nullglob; for i in $(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)/$(AVM_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(KERNEL_BUILD_DIR)/kernel $$i; \
	done
	@for i in $(KERNEL_LINKING_FILES); do \
		if test -e $(KERNEL_BUILD_ROOT_DIR)/$$i -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}; then \
			echo "Linking  .../include/linux/$${i##*\/linux_}"; \
			ln -sf ../../$$i $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}; \
		fi \
	done
	@if test -e $(KERNEL_BUILD_ROOT_DIR)/drivers/char/avm_net_trace/avm_net_trace.h -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/avm_net_trace.h; then \
			echo "Linking  .../include/linux/avm_net_trace.h"; \
			ln -sf ../../drivers/char/avm_net_trace/avm_net_trace.h \
				$(KERNEL_BUILD_ROOT_DIR)/include/linux/avm_net_trace.h; \
	fi
	@for i in $(KERNEL_DUMMY_MAKE_FILES); do \
		if test -e $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile.26 -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile ; then \
			echo "Linking  .../$$i/Makefile"; \
			ln -sf Makefile.26 $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile; \
		fi \
	done
	@for i in $(KERNEL_DUMMY_DIRS); do \
		if test ! -e $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile ; then \
			echo Creating .../$$i/Makefile; \
			mkdir -p $(KERNEL_BUILD_ROOT_DIR)/$$i; \
			test -h $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile && \
				rm $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile; \
			touch $(KERNEL_BUILD_ROOT_DIR)/$$i/Makefile; \
		fi \
	done
	@for i in $(KERNEL_OTHER_FILES); do \
		if test ! -e $(KERNEL_BUILD_ROOT_DIR)/$$i ; then \
			echo Creating  .../$$i; \
			mkdir -p $(KERNEL_BUILD_ROOT_DIR)/$${i%\/*}; \
			test -h $(KERNEL_BUILD_ROOT_DIR)/$$i && \
				rm $(KERNEL_BUILD_ROOT_DIR)/$$i; \
			touch $(KERNEL_BUILD_ROOT_DIR)/$$i; \
		fi \
	done
	ln -s $(KERNEL_BUILD_DIR_N)/kernel/linux-$(KERNEL_VERSION) $(KERNEL_DIR)/linux
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_ROOT_DIR)/.config
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		oldconfig
	touch $@

$(KERNEL_DIR)/.depend_done: $(KERNEL_DIR)/.configured
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		ARCH="$(KERNEL_ARCH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		prepare
	touch $@

$(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.depend_done $(TOOLS_DIR)/lzma $(TOOLS_DIR)/lzma2eva
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(notdir $(KERNEL_IMAGE))
	touch -c $@

kernel-force:
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		ARCH=$(KERNEL_ARCH) \
		$(notdir $(KERNEL_IMAGE))

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	cp $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp $(KERNEL_BUILD_ROOT_DIR)/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_REF)-$(AVM_VERSION).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_REF)-$(AVM_VERSION)
	touch -c $@

$(KERNEL_DIR)/.modules-$(KERNEL_LAYOUT): $(KERNEL_BUILD_DIR)/$(KERNEL_IMAGE)
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		ARCH=$(KERNEL_ARCH) \
		INSTALL_MOD_PATH="$(shell pwd)/$(KERNEL_BUILD_DIR)/modules/" \
		modules
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
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

kernel-menuconfig: $(KERNEL_DIR)/.configured
		PATH=$(KERNEL_MAKE_PATH):$(PATH) \
		$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
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
	PATH=$(KERNEL_MAKE_PATH):$(PATH) \
	$(MAKE) -C $(KERNEL_BUILD_ROOT_DIR) \
		CROSS_COMPILE="$(KERNEL_CROSS)" \
		KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		KERNEL_LAYOUT="$(KERNEL_BOARD_REF)" \
		clean

kernel-dirclean:
	$(RM) -r $(KERNEL_DIR)
	$(RM) -r $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)

kernel-distclean: kernel-dirclean
	$(RM) $(KERNEL_TARGET_DIR)/.version-*
	$(RM) $(KERNEL_TARGET_DIR)/System*
	$(RM) $(KERNEL_TARGET_DIR)/kernel-*
	$(RM) -r $(KERNEL_TARGET_DIR)/modules-*

.PHONY: kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig
