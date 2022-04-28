BINUTILS_KERNEL_VERSION:=$(KERNEL_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_KERNEL_SOURCE:=binutils-$(BINUTILS_KERNEL_VERSION).tar.bz2
BINUTILS_KERNEL_SITE:=@GNU/binutils
BINUTILS_KERNEL_MD5_2.18   := ccd264a5fa9ed992a21427c69cba91d3
BINUTILS_KERNEL_MD5_2.22   := ee0f10756c84979622b992a4a61ea3f5
BINUTILS_KERNEL_MD5_2.23.2 := 4f8fa651e35ef262edc01d60fb45702e
BINUTILS_KERNEL_MD5_2.24   := e0f71a7b2ddab0f8612336ac81d9636b
BINUTILS_KERNEL_MD5_2.25.1 := ac493a78de4fee895961d025b7905be4
BINUTILS_KERNEL_MD5_2.26.1 := d2b24e5b5301b7ff0207414c34c3e0fb
BINUTILS_KERNEL_MD5_2.31.1 := 84edf97113788f106d6ee027f10b046a
BINUTILS_KERNEL_MD5        := $(BINUTILS_KERNEL_MD5_$(BINUTILS_KERNEL_VERSION))

BINUTILS_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/binutils-$(BINUTILS_KERNEL_VERSION)
BINUTILS_KERNEL_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/kernel/binutils
BINUTILS_KERNEL_DIR1:=$(BINUTILS_KERNEL_DIR)-build

BINUTILS_KERNEL_CFLAGS := $(TOOLCHAIN_HOST_CFLAGS)
ifeq ($(strip $(FREETZ_AVM_GCC_3_4_MAX)),y)
BINUTILS_KERNEL_CFLAGS += -fcommon
endif

BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS := MAKEINFO=true

binutils-kernel-source: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
$(DL_DIR)/$(BINUTILS_KERNEL_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(BINUTILS_KERNEL_SOURCE) $(BINUTILS_KERNEL_SITE) $(BINUTILS_KERNEL_MD5)

binutils-kernel-unpacked: $(BINUTILS_KERNEL_DIR)/.unpacked
$(BINUTILS_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE) | $(KERNEL_TOOLCHAIN_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(RM) -r $(BINUTILS_KERNEL_DIR)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(BINUTILS_KERNEL_SOURCE),$(KERNEL_TOOLCHAIN_DIR))
	$(call APPLY_PATCHES,$(BINUTILS_KERNEL_MAKE_DIR)/$(call GET_MAJOR_VERSION,$(BINUTILS_KERNEL_VERSION)),$(BINUTILS_KERNEL_DIR))
	# fool zlib test in all configure scripts so it doesn't find zlib and thus no zlib gets linked in
	sed -i -r -e 's,(zlibVersion)([ \t]*[(][)]),\1WeDontWantZlib\2,g' $$(find $(BINUTILS_KERNEL_DIR) -name "configure" -type f)
	touch $@

$(BINUTILS_KERNEL_DIR1)/.configured: $(BINUTILS_KERNEL_DIR)/.unpacked
	mkdir -p $(BINUTILS_KERNEL_DIR1)
	(cd $(BINUTILS_KERNEL_DIR1); \
		CC="$(TOOLCHAIN_HOSTCC)" \
		CFLAGS="$(BINUTILS_KERNEL_CFLAGS)" \
		$(BINUTILS_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		--disable-multilib \
		$(DISABLE_NLS) \
		--disable-werror \
		--without-headers \
		$(QUIET) \
	);
	touch $@

$(BINUTILS_KERNEL_DIR1)/.compiled: $(BINUTILS_KERNEL_DIR1)/.configured
	$(MAKE) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) configure-host
	$(MAKE) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) all
	touch $@

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld: $(BINUTILS_KERNEL_DIR1)/.compiled
	$(MAKE1) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) install
	$(RM) $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld.bfd $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-ld.bfd
	$(call STRIP_TOOLCHAIN_BINARIES,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(BINUTILS_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(KERNEL_TOOLCHAIN_STAGING_DIR))

binutils-dependencies:
	@MISSING_PREREQ=""; \
	for f in bison flex; do \
		if ! which $$f >/dev/null 2>&1; then MISSING_PREREQ="$$MISSING_PREREQ $$f"; fi; \
	done; \
	if [ -n "$$MISSING_PREREQ" ]; then \
		echo -n -e "$(_Y)"; \
		echo -e \
			"ERROR: The following commands required for building of binutils-kernel are missing on your system:" \
			`echo $$MISSING_PREREQ | sed -e 's| |, |g'`; \
		echo -n -e "$(_N)"; \
		exit 1; \
	fi;

binutils-kernel-uninstall:
	$(RM) $(call TOOLCHAIN_BINARIES_LIST,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(BINUTILS_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME))
	$(RM) -r $(KERNEL_TOOLCHAIN_STAGING_DIR)/lib{,64}/{libiberty*,ldscripts}

binutils-kernel-clean: binutils-kernel-uninstall
	$(RM) -r $(BINUTILS_KERNEL_DIR1)

binutils-kernel-dirclean: binutils-kernel-clean
	$(RM) -r $(BINUTILS_KERNEL_DIR)

binutils-kernel: binutils-dependencies $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld

.PHONY: binutils-kernel binutils-kernel-source binutils-kernel-unpacked binutils-dependencies binutils-kernel-uninstall binutils-kernel-clean binutils-kernel-dirclean
