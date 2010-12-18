BINUTILS_KERNEL_VERSION:=$(KERNEL_TOOLCHAIN_BINUTILS_VERSION)
BINUTILS_KERNEL_SOURCE:=binutils-$(BINUTILS_KERNEL_VERSION).tar.bz2
ifeq ($(KERNEL_TOOLCHAIN_BINUTILS_MAJOR_VERSION),2.18)
BINUTILS_KERNEL_SITE:=@GNU/binutils
else
BINUTILS_KERNEL_SITE:=@KERNEL/linux/devel/binutils
endif
BINUTILS_KERNEL_MD5_2.18         := 9d22ee4dafa3a194457caf4706f9cf01
BINUTILS_KERNEL_MD5_2.21.51.0.4  := 4a462be596b2c4d6b906dff713b7916a
BINUTILS_KERNEL_MD5              := $(BINUTILS_KERNEL_MD5_$(BINUTILS_KERNEL_VERSION))

BINUTILS_KERNEL_DIR:=$(KERNEL_TOOLCHAIN_DIR)/binutils-$(BINUTILS_KERNEL_VERSION)
BINUTILS_KERNEL_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/kernel/binutils
BINUTILS_KERNEL_DIR1:=$(BINUTILS_KERNEL_DIR)-build

BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS :=
ifeq ($(strip $(FREETZ_STATIC_TOOLCHAIN)),y)
BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS += "LDFLAGS=-all-static"
endif

binutils-kernel-source: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
ifneq ($(strip $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)), $(strip $(DL_DIR)/$(BINUTILS_SOURCE)))
$(DL_DIR)/$(BINUTILS_KERNEL_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(BINUTILS_KERNEL_SOURCE) $(BINUTILS_KERNEL_SITE) $(BINUTILS_KERNEL_MD5)
endif

$(BINUTILS_KERNEL_DIR)/.unpacked: $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
	mkdir -p $(KERNEL_TOOLCHAIN_DIR)
	tar -C $(KERNEL_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(BINUTILS_KERNEL_SOURCE)
	set -e; \
	for i in $(BINUTILS_KERNEL_MAKE_DIR)/$(BINUTILS_KERNEL_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(BINUTILS_KERNEL_DIR) $$i; \
	done
	touch $@

$(BINUTILS_KERNEL_DIR1)/.configured: $(BINUTILS_KERNEL_DIR)/.unpacked
	mkdir -p $(BINUTILS_KERNEL_DIR1)
	(cd $(BINUTILS_KERNEL_DIR1); \
		CC="$(HOSTCC)" \
		$(BINUTILS_KERNEL_DIR)/configure \
		--prefix=$(KERNEL_TOOLCHAIN_STAGING_DIR) \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(REAL_GNU_KERNEL_NAME) \
		$(DISABLE_NLS) \
		--disable-werror \
		--without-headers \
		$(QUIET) \
	);
	touch $@

$(BINUTILS_KERNEL_DIR1)/.compiled: $(BINUTILS_KERNEL_DIR1)/.configured
	$(MAKE) -C $(BINUTILS_KERNEL_DIR1) configure-host
	$(MAKE) $(BINUTILS_KERNEL_EXTRA_MAKE_OPTIONS) -C $(BINUTILS_KERNEL_DIR1) all
	touch $@

$(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld: $(BINUTILS_KERNEL_DIR1)/.compiled
	$(MAKE1) -C $(BINUTILS_KERNEL_DIR1) install
	$(call STRIP_TOOLCHAIN_BINARIES,$(KERNEL_TOOLCHAIN_STAGING_DIR),$(BINUTILS_BINARIES_BIN),$(REAL_GNU_KERNEL_NAME),$(HOST_STRIP))
	$(call REMOVE_DOC_NLS_DIRS,$(KERNEL_TOOLCHAIN_STAGING_DIR))

binutils-dependencies:
	@MISSING_PREREQ=""; \
	for f in bison flex msgfmt; do \
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
	$(RM) -r $(KERNEL_TOOLCHAIN_STAGING_DIR)/lib/{libiberty*,ldscripts}

binutils-kernel-clean: binutils-kernel-uninstall
	$(RM) -r $(BINUTILS_KERNEL_DIR1)

binutils-kernel-dirclean: binutils-kernel-clean
	$(RM) -r $(BINUTILS_KERNEL_DIR)

binutils-kernel: binutils-dependencies $(KERNEL_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_KERNEL_NAME)/bin/ld

.PHONY: binutils binutils-dependencies
