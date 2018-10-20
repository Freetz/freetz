KERNEL_SUBVERSION:=iln6

KERNEL_MAKE_DIR:=$(MAKE_DIR)/linux
KERNEL_PATCHES_DIR:=$(KERNEL_MAKE_DIR)/patches/$(KERNEL_VERSION)$(SYSTEM_TYPE_CORE_SUFFIX)
KERNEL_BUILD_ROOT_DIR:=$(KERNEL_DIR)/linux-$(KERNEL_VERSION_SOURCES_SUBDIR)

KERNEL_IMAGE:=vmlinux.eva_pad
KERNEL_IMAGE_BUILD_SUBDIR:=$(if $(FREETZ_KERNEL_VERSION_3_10_MIN),/arch/$(KERNEL_ARCH)/boot)
KERNEL_TARGET_BINARY:=kernel-$(KERNEL_ID).bin
KERNEL_CONFIG_FILE:=$(KERNEL_MAKE_DIR)/configs/freetz/config-$(KERNEL_ID)

KERNEL_COMMON_MAKE_OPTIONS := -C $(KERNEL_BUILD_ROOT_DIR)
KERNEL_COMMON_MAKE_OPTIONS += CROSS_COMPILE="$(KERNEL_CROSS)"
KERNEL_COMMON_MAKE_OPTIONS += KERNEL_MAKE_PATH="$(KERNEL_MAKE_PATH):$(PATH)"
KERNEL_COMMON_MAKE_OPTIONS += ARCH="$(KERNEL_ARCH)"
# TODO: KERNEL_LAYOUT is referenced just once in kernel's makefiles.
# It causes additional fusiv-sources to be added to the list of sources
# to compile. Compiling these sources however fails, that's the reason
# the following line is commented out.
#KERNEL_COMMON_MAKE_OPTIONS += KERNEL_LAYOUT="$(SYSTEM_TYPE)"
KERNEL_COMMON_MAKE_OPTIONS += INSTALL_HDR_PATH=$(KERNEL_HEADERS_DEVEL_DIR)
KERNEL_COMMON_MAKE_OPTIONS += INSTALL_MOD_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_DIR)"
ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
KERNEL_COMMON_MAKE_OPTIONS += V=1
endif

$(DL_FW_DIR)/$(call qstrip,$(FREETZ_DL_KERNEL_SOURCE)): | $(DL_FW_DIR)
	@$(call _ECHO, downloading...)
	$(DL_TOOL) $(DL_FW_DIR) $(FREETZ_DL_KERNEL_SOURCE) $(FREETZ_DL_KERNEL_SITE) $(FREETZ_DL_KERNEL_SOURCE_MD5) $(SILENT)

# Make sure that a perfectly clean build is performed whenever Freetz package
# options have changed. The safest way to achieve this is by starting over
# with the source directory.
KERNEL_VERSION_SOURCES_SUBDIR_ESCAPED:=$(subst .,\.,$(KERNEL_VERSION_SOURCES_SUBDIR))
AVM_UNPACK__INT_.gz:=z
AVM_UNPACK__INT_.bz2:=j
kernel-unpacked: $(KERNEL_DIR)/.unpacked
$(KERNEL_DIR)/.unpacked: $(DL_FW_DIR)/$(call qstrip,$(FREETZ_DL_KERNEL_SOURCE)) | gcc-kernel
	$(RM) -r $(KERNEL_DIR)
	mkdir -p $(KERNEL_DIR)
	@$(call _ECHO,checking structure... )
	@KERNEL_SOURCE_CONTENT=$$( \
		$(TAR) -t$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) -f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
		| grep -E '(GPL-(release_)?kernel\.tar\.gz|linux-$(KERNEL_VERSION_SOURCES_SUBDIR_ESCAPED)/)$$' \
		| head -n1 \
	); \
	if [ -z "$${KERNEL_SOURCE_CONTENT}" ]; then \
		$(call ERROR,1,KERNEL_SOURCE_CONTENT is empty) \
	else \
		$(call _ECHO, unpacking... ) \
		if echo "$${KERNEL_SOURCE_CONTENT}" | grep -qE 'GPL-(release_)?kernel\.tar\.gz$$'; then \
			$(TAR)	-O $(VERBOSE) \
				-x$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
				-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
				--wildcards "*/$${KERNEL_SOURCE_CONTENT##*/}" | \
			$(TAR)	-C $(KERNEL_DIR) $(VERBOSE) \
				-xz \
				--transform="s|^.*\(linux-$(KERNEL_VERSION_SOURCES_SUBDIR_ESCAPED)/\)|\1|g" --show-transformed; \
		else \
			$(TAR)	-C $(KERNEL_DIR) $(VERBOSE) \
				-x$(AVM_UNPACK__INT_$(suffix $(strip $(FREETZ_DL_KERNEL_SOURCE)))) \
				-f $(DL_FW_DIR)/$(FREETZ_DL_KERNEL_SOURCE) \
				--transform="s|^.*\(linux-$(KERNEL_VERSION_SOURCES_SUBDIR_ESCAPED)/\)|\1|g" --show-transformed "$${KERNEL_SOURCE_CONTENT}"; \
		fi \
	fi
	@if [ ! -d $(KERNEL_BUILD_ROOT_DIR) ]; then \
		$(call ERROR,1,KERNEL_BUILD_ROOT_DIR has wrong structure) \
	fi
	@$(call _ECHO, preparing... )
	#kernel version specific patches
	@$(call APPLY_PATCHES,$(KERNEL_PATCHES_DIR),$(KERNEL_DIR))
	#firmware version specific patches
	@$(call APPLY_PATCHES,$(KERNEL_PATCHES_DIR)/$(AVM_SOURCE_ID),$(KERNEL_DIR))
	@for i in $(KERNEL_LINKING_FILES); do \
		if [ -e $(KERNEL_BUILD_ROOT_DIR)/$$i -a \
		! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_} ]; then \
			$(call MESSAGE, Linking  $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}); \
			ln -sf ../../$$i $(KERNEL_BUILD_ROOT_DIR)/include/linux/$${i##*\/linux_}; \
		fi \
	done
	@for i in avm_net_trace.h avm_net_trace_ioctl.h; do \
		if [ -e $(KERNEL_BUILD_ROOT_DIR)/drivers/char/avm_net_trace/$$i -a \
			! -e $(KERNEL_BUILD_ROOT_DIR)/include/linux/$$i ]; then \
				$(call MESSAGE, Linking  $(KERNEL_BUILD_ROOT_DIR)/include/linux/$$i); \
				ln -sf ../../drivers/char/avm_net_trace/$$i \
					$(KERNEL_BUILD_ROOT_DIR)/include/linux/$$i; \
		fi \
	done
	@for i in $$(find $(KERNEL_BUILD_ROOT_DIR) -name Makefile.26 -printf '%h\n'); do \
		if [ ! -e $$i/Makefile ] ; then \
			$(call MESSAGE, Linking  $$i/Makefile); \
			ln -sf Makefile.26 $$i/Makefile; \
		fi \
	done
	@for i in $$( \
		find $(KERNEL_BUILD_ROOT_DIR) -name Makefile -exec \
		awk '/(obj|subdir)-.*=/ && !/(obj|subdir)-ccflags.*=/ { \
			while (match ($$0,/\\/)) {sub(/\\/," "); getline l;$$0=$$0""l} \
			sub(/\r/,""); \
			gsub(/(#.*|.*=)/,""); \
			if (! match ($$0,/,/)) { \
				dirname=substr(FILENAME,1,length(FILENAME)-8); \
				for (i=1;i<=NF;i++) { \
					if (match ($$i,/\.o$$|\.lds$$|\$$/)) { \
						$$i=""; \
					} else if (substr($$i,length($$i))!="/") { \
						$$i=$$i"/"; \
					} \
					if ($$i!="") { \
						if (system("test -e "dirname""$$i"Makefile")) { \
							print dirname""$$i"Makefile"; \
						} \
					} \
				} \
			} \
		}' {} '+' \
		| sort -u \
	); do \
		$(call MESSAGE, Creating $$i); \
		mkdir -p $$(dirname "$$i"); \
		[ -h $$i ] && $(RM) $$i; \
		touch $$i; \
	done
	@for i in $$( \
		find $(KERNEL_BUILD_ROOT_DIR) -name Kconfig -exec grep -hs "source.*Kconfig" {} '+' \
		| sed -e 's/\(.*\)#.*/\1/g;s/.*source //g;s/"//g' \
		| sort -u \
	); do \
		if [ ! -e $(KERNEL_BUILD_ROOT_DIR)/$$i ]; then \
			$(call MESSAGE, Creating $(KERNEL_BUILD_ROOT_DIR)/$$i); \
			mkdir -p $(KERNEL_BUILD_ROOT_DIR)/$${i%\/*}; \
			[ -h $(KERNEL_BUILD_ROOT_DIR)/$$i ] && $(RM) $(KERNEL_BUILD_ROOT_DIR)/$$i; \
			touch $(KERNEL_BUILD_ROOT_DIR)/$$i; \
		fi \
	done
	ln -s linux-$(KERNEL_VERSION_SOURCES_SUBDIR) $(KERNEL_DIR)/linux
	touch $@

$(KERNEL_DIR)/.configured: $(KERNEL_DIR)/.unpacked $(KERNEL_CONFIG_FILE)
	$(call _ECHO, configuring... )
	cp $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_ROOT_DIR)/.config
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) oldconfig
	touch $@

$(KERNEL_DIR)/.prepared: $(KERNEL_DIR)/.configured
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) prepare
	touch $@

$(KERNEL_HEADERS_DEVEL_DIR)/include/linux/version.h: $(KERNEL_DIR)/.prepared
ifeq ($(strip $(FREETZ_KERNEL_VERSION_2_6_13)),y)
	$(call COPY_KERNEL_HEADERS,$(KERNEL_BUILD_ROOT_DIR),$(KERNEL_HEADERS_DEVEL_DIR),{asm$(_comma)asm-generic$(_comma)linux$(_comma)mtd$(_comma)scsi$(_comma)video})
else
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) headers_install
	find "$(KERNEL_HEADERS_DEVEL_DIR)" \( -name "..install.cmd" -o -name ".install" \) -exec rm -f \{\} \+
endif
	touch $@

target-toolchain-kernel-headers: $(TARGET_TOOLCHAIN_KERNEL_VERSION_HEADER)
$(TARGET_TOOLCHAIN_KERNEL_VERSION_HEADER): $(TOPDIR)/.config $(KERNEL_HEADERS_DEVEL_DIR)/include/linux/version.h | $(if $(FREETZ_BUILD_TOOLCHAIN),$(TARGET_TOOLCHAIN_STAGING_DIR),$(TARGET_CROSS_COMPILER))
	@$(call COPY_KERNEL_HEADERS,$(KERNEL_HEADERS_DEVEL_DIR),$(TARGET_TOOLCHAIN_STAGING_DIR)/usr)
	@touch $@

ifeq ($(strip $(FREETZ_KERNEL_VERSION_3_10_MIN)),y)
KERNEL_BUILD_DEPENDENCIES += $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S

$(AVM_KERNEL_CONFIG_DIR): | $(KERNEL_DIR)/.unpacked
	@mkdir -p $@

$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).bin: $(DL_FW_DIR)/$(DL_SOURCE) | $(KERNEL_DIR)/.unpacked $(AVM_KERNEL_CONFIG_DIR) tools
	@$(TOOLS_DIR)/avm_kernel_config.extract.sh -s $(FREETZ_AVM_KERNEL_CONFIG_AREA_SIZE) "$<" >"$@" || { $(RM) "$@"; exit 1; }

$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).S: $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).bin | $(KERNEL_DIR)/.unpacked $(AVM_KERNEL_CONFIG_DIR) tools
	@$(TOOLS_DIR)/avm_kernel_config.bin2asm "$<" >"$@" || { $(RM) "$@"; exit 1; }

# Force kernel rebuild if avm_kernel_config_area.S differs from avm_kernel_config_area.$(DL_SOURCE_ID).S
# To reduce maintenance effort we often use the same opensrc package for different boxes.
# avm_kernel_config_area is however box/firmware-release specific, i.e. the kernel must be rebuilt
# if BOX_ID changes even though the opensrc package might still be the same.
$(shell diff -q "$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S" "$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).S" >/dev/null 2>&1 || $(RM) "$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S" >/dev/null 2>&1)

$(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S: $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.$(DL_SOURCE_ID).S
	@cat "$<" >"$@"

.PHONY: avm_kernel_config
avm_kernel_config: $(AVM_KERNEL_CONFIG_DIR)/avm_kernel_config_area.S
endif

$(KERNEL_BUILD_ROOT_DIR)$(KERNEL_IMAGE_BUILD_SUBDIR)/$(KERNEL_IMAGE): $(KERNEL_DIR)/.prepared $(KERNEL_BUILD_DEPENDENCIES) | $(TOOLS_DIR)/lzma $(TOOLS_DIR)/lzma2eva
	$(call _ECHO, kernel image... )
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) $(KERNEL_IMAGE)
	touch -c $@

$(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY): $(KERNEL_BUILD_ROOT_DIR)$(KERNEL_IMAGE_BUILD_SUBDIR)/$(KERNEL_IMAGE) | $(KERNEL_TARGET_DIR)
	cp $(KERNEL_BUILD_ROOT_DIR)$(KERNEL_IMAGE_BUILD_SUBDIR)/$(KERNEL_IMAGE) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	cp $(KERNEL_BUILD_ROOT_DIR)/System.map $(KERNEL_TARGET_DIR)/System-$(KERNEL_ID).map
	echo "$(KERNEL_SUBVERSION)" > $(KERNEL_TARGET_DIR)/.version-$(KERNEL_ID)
	touch -c $@

$(KERNEL_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX): $(KERNEL_BUILD_ROOT_DIR)$(KERNEL_IMAGE_BUILD_SUBDIR)/$(KERNEL_IMAGE)
	@$(call _ECHO, modules... )
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) modules
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) modules_install
	touch $@

$(KERNEL_MODULES_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX): $(KERNEL_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX)
	$(RM) -r $(KERNEL_MODULES_DIR)/lib
	mkdir -p $(KERNEL_MODULES_DIR)
	$(call COPY_USING_TAR,$(KERNEL_DIR)/lib/modules/$(call qstrip,$(FREETZ_KERNEL_VERSION_MODULES_SUBDIR))/kernel,$(KERNEL_MODULES_DIR))
	touch $@

kernel-precompiled: pkg-echo-start $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY) $(KERNEL_MODULES_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX) pkg-echo-done

kernel-configured: $(KERNEL_DIR)/.prepared

kernel-modules: $(KERNEL_DIR)/.modules-$(SYSTEM_TYPE)$(SYSTEM_TYPE_CORE_SUFFIX)

kernel-help:
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) help

kernel-menuconfig: $(KERNEL_DIR)/.configured
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) menuconfig
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-xconfig: $(KERNEL_DIR)/.configured
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) xconfig
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-oldconfig: $(KERNEL_DIR)/.configured
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE) && \
	touch $(KERNEL_DIR)/.configured

kernel-source: $(KERNEL_DIR)/.unpacked

kernel-clean:
	-$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) clean

kernel-mrproper:
	-cp -f $(KERNEL_BUILD_ROOT_DIR)/.config $(KERNEL_CONFIG_FILE)
	$(SUBMAKE) $(KERNEL_COMMON_MAKE_OPTIONS) mrproper
	-cp -f $(KERNEL_CONFIG_FILE) $(KERNEL_BUILD_ROOT_DIR)/.config
	-$(SUBMAKE) kernel-oldconfig

kernel-dirclean:
	$(RM) -r $(KERNEL_DIR)
	$(RM) -r $(KERNEL_HEADERS_DEVEL_DIR) $(addprefix $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/,$(KERNEL_HEADERS_SUBDIRS))
	$(RM) $(KERNEL_TARGET_DIR)/.version-$(KERNEL_ID)
	$(RM) $(KERNEL_TARGET_DIR)/System-$(KERNEL_ID).map
	$(RM) $(KERNEL_TARGET_DIR)/$(KERNEL_TARGET_BINARY)
	$(RM) -r $(KERNEL_TARGET_DIR)/modules-$(KERNEL_ID)

pkg-echo-start:
	@$(RM) $(ECHO_ITEM_START) $(ECHO_ITEM_BUILD)

pkg-echo-done:
	@$(call _ECHO_DONE)

.PHONY: kernel-unpacked kernel-configured kernel-modules kernel-menuconfig kernel-oldconfig target-toolchain-kernel-headers
