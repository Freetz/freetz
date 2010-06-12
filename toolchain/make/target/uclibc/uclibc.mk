UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/uclibc
UCLIBC_SOURCE:=uClibc-$(UCLIBC_VERSION).tar.bz2
UCLIBC_SOURCE_SITE:=http://www.uclibc.org/downloads
UCLIBC_SOURCE_SITE2:=http://www.uclibc.org/downloads/old-releases

UCLIBC_KERNEL_SOURCE_DIR:=$(KERNEL_SOURCE_DIR)
UCLIBC_KERNEL_HEADERS_DIR:=$(KERNEL_HEADERS_DIR)

UCLIBC_DEVEL_SUBDIR:=uClibc_dev

# uClibc pregenerated locale data
UCLIBC_SITE_LOCALE:=http://www.uclibc.org/downloads
UCLIBC_SOURCE_LOCALE:=uClibc-locale-030818.tgz

ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
UCLIBC_VERBOSE_BUILD_FLAGS := V=1
endif

$(DL_DIR)/$(UCLIBC_SOURCE_LOCALE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(UCLIBC_SOURCE_LOCALE) $(UCLIBC_SITE_LOCALE)

UCLIBC_LOCALE_DATA:=$(DL_DIR)/$(UCLIBC_SOURCE_LOCALE)


$(DL_DIR)/$(UCLIBC_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(UCLIBC_SOURCE) $(UCLIBC_SOURCE_SITE) || $(DL_TOOL) $(DL_DIR) .config $(UCLIBC_SOURCE) $(UCLIBC_SOURCE_SITE2)

uclibc-unpacked: $(UCLIBC_DIR)/.unpacked
$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE) $(UCLIBC_LOCALE_DATA)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(UCLIBC_SOURCE)
	touch $@

uclibc-patched: $(UCLIBC_DIR)/.patched
$(UCLIBC_DIR)/.patched: $(UCLIBC_DIR)/.unpacked
	set -e; \
	for i in $(UCLIBC_MAKE_DIR)/$(UCLIBC_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(UCLIBC_DIR) $$i; \
	done
	cp -dpf $(UCLIBC_LOCALE_DATA) $(UCLIBC_DIR)/extra/locale/
# TODO: uClibc-0.9.30x tries to download this file, it is however not available on uClibc' website
	cp -dpf $(UCLIBC_LOCALE_DATA) $(UCLIBC_DIR)/extra/locale/uClibc-locale-20081111-32-el.tgz
	touch $@

$(UCLIBC_DIR)/.config: $(UCLIBC_DIR)/.patched
	cp $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF).$(UCLIBC_VERSION) $(UCLIBC_DIR)/.config
ifeq ($(strip $(UCLIBC_VERSION)),0.9.28)
	$(SED) -i -e 's,^KERNEL_SOURCE=.*,KERNEL_SOURCE=\"$(shell pwd)/$(UCLIBC_KERNEL_SOURCE_DIR)\",g' $(UCLIBC_DIR)/.config
else
	$(SED) -i -e 's,^KERNEL_HEADERS=.*,KERNEL_HEADERS=\"$(shell pwd)/$(UCLIBC_KERNEL_HEADERS_DIR)\",g' $(UCLIBC_DIR)/.config
endif
	$(SED) -i -e 's,^CROSS=.*,CROSS=$(TARGET_MAKE_PATH)/$(TARGET_CROSS),g' $(UCLIBC_DIR)/Rules.mak
ifeq ($(strip $(FREETZ_TARGET_IPV6_SUPPORT)),y)
	$(SED) -i -e 's,.*UCLIBC_HAS_IPV6.*,UCLIBC_HAS_IPV6=y,g' $(UCLIBC_DIR)/.config
else
	$(SED) -i -e 's,.*UCLIBC_HAS_IPV6.*,# UCLIBC_HAS_IPV6 is not set,g' $(UCLIBC_DIR)/.config
endif
ifeq ($(strip $(FREETZ_TARGET_LFS)),y)
	$(SED) -i -e 's,.*UCLIBC_HAS_LFS.*,UCLIBC_HAS_LFS=y,g' $(UCLIBC_DIR)/.config
else
	$(SED) -i -e 's,.*UCLIBC_HAS_LFS.*,# UCLIBC_HAS_LFS is not set,g' $(UCLIBC_DIR)/.config
endif
	$(SED) -i -e '/.*UCLIBC_HAS_FOPEN_LARGEFILE_MODE.*/d' $(UCLIBC_DIR)/.config
	echo "# UCLIBC_HAS_FOPEN_LARGEFILE_MODE is not set" >> $(UCLIBC_DIR)/.config
	$(SED) 's,.*UCLIBC_HAS_WCHAR.*,UCLIBC_HAS_WCHAR=y,g' $(UCLIBC_DIR)/.config
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/include
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/lib
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(HOSTCC)" \
		oldconfig
	touch $@

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.config
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(HOSTCC)" headers \
		$(if $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28),install_dev,install_headers)
	# Install the kernel headers to the first stage gcc include dir if necessary
	if [ ! -f $(TARGET_TOOLCHAIN_STAGING_DIR)/include/linux/version.h ] ; then \
		cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/include/ ; \
		cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/linux $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/include/ ; \
		if [ -d $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic ] ; then \
			cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic \
			$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/usr/include/ ; \
		fi; \
	fi;
	touch $@

uclibc-menuconfig: $(UCLIBC_DIR)/.config
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/ \
		HOSTCC="$(HOSTCC)" \
		menuconfig && \
	cp -f $^ $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF).$(UCLIBC_VERSION) && \
	touch $^

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured $(gcc_initial)
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX= \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		HOSTCC="$(HOSTCC)" \
		all
	touch -c $@

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX=/ \
		DEVEL_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/ \
		install_runtime install_dev
	# Install the kernel headers to the staging dir if necessary
	if [ ! -f $(TARGET_TOOLCHAIN_STAGING_DIR)/include/linux/version.h ] ; then \
		cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ ; \
		cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/linux $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ ; \
		if [ -d $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic ] ; then \
			cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/ ; \
		fi; \
	fi;
	# Build the host utils.
	$(MAKE1) -C $(UCLIBC_DIR)/utils \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		HOSTCC="$(HOSTCC)" \
		hostutils
	install -c $(UCLIBC_DIR)/utils/ldd.host $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ldd
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/ldd $(REAL_GNU_TARGET_NAME)-ldd)
	install -c $(UCLIBC_DIR)/utils/ldconfig.host $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/bin/ldconfig
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin; ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/ldconfig $(REAL_GNU_TARGET_NAME)-ldconfig)
	touch -c $@

$(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX="$(FREETZ_BASE_DIR)/$(TARGET_SPECIFIC_ROOT_DIR)" \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		install_runtime
	touch -c $@
else
cross_compiler:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc
$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a: $(cross_compiler)
	touch -c $@

$(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	@$(RM) -r $(TARGET_SPECIFIC_ROOT_DIR)/lib
	@mkdir -p $(TARGET_SPECIFIC_ROOT_DIR)/lib
	for i in $(UCLIBC_FILES); do \
		cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$$i $(TARGET_SPECIFIC_ROOT_DIR)/lib/$$i; \
	done
	ln -sf libuClibc-$(UCLIBC_VERSION).so $(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so
	touch -c $@
endif

uclibc-configured: kernel-configured $(UCLIBC_DIR)/.configured

uclibc: $(cross_compiler) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a $(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so.0

uclibc-source: $(DL_DIR)/$(UCLIBC_SOURCE)

uclibc-configured-source: uclibc-source

uclibc-clean:
	-$(MAKE1) -C $(UCLIBC_DIR) clean
	$(RM) $(UCLIBC_DIR)/.config

uclibc-dirclean:
	$(RM) -r $(UCLIBC_DIR)

.PHONY: uclibc-configured uclibc

#############################################################
#
# uClibc for the target
#
#############################################################

$(TARGET_UTILS_DIR)/usr/lib/libc.a: | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		$(UCLIBC_VERBOSE_BUILD_FLAGS) \
		PREFIX=$(TARGET_UTILS_DIR) \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		UCLIBC_EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		UCLIBC_EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		install_dev
	# Install the kernel headers to the target dir if necessary
	if [ ! -f $(TARGET_UTILS_DIR)/usr/include/linux/version.h ]; then \
		cp -pLR $(TARGET_TOOLCHAIN_STAGING_DIR)/include/* \
			$(TARGET_UTILS_DIR)/usr/include/; \
	fi
	touch -c $@

uclibc_target: cross_compiler uclibc $(TARGET_UTILS_DIR)/usr/lib/libc.a

uclibc_target-clean:
	$(RM) -r $(TARGET_UTILS_DIR)/usr/include $(TARGET_UTILS_DIR)/lib/libc.a

uclibc_target-dirclean:
	$(RM) -r $(TARGET_UTILS_DIR)/usr/include
