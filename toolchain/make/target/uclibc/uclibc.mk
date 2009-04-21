UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/uclibc
UCLIBC_SOURCE:=uClibc-$(UCLIBC_VERSION).tar.bz2
UCLIBC_SOURCE_SITE:=http://www.uclibc.org/downloads
UCLIBC_KERNEL_SOURCE_DIR:=$(KERNEL_SOURCE_DIR)
UCLIBC_KERNEL_HEADERS_DIR:=$(KERNEL_HEADERS_DIR)

# uClibc pregenerated locale data
UCLIBC_SITE_LOCALE:=http://www.uclibc.org/downloads
UCLIBC_SOURCE_LOCALE:=uClibc-locale-030818.tgz

$(DL_DIR)/$(UCLIBC_SOURCE_LOCALE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(UCLIBC_SOURCE_LOCALE) $(UCLIBC_SITE_LOCALE)

UCLIBC_LOCALE_DATA:=$(DL_DIR)/$(UCLIBC_SOURCE_LOCALE)


$(DL_DIR)/$(UCLIBC_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) .config $(UCLIBC_SOURCE) $(UCLIBC_SOURCE_SITE)

uclibc-unpacked: $(UCLIBC_DIR)/.unpacked
$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE) $(UCLIBC_LOCALE_DATA)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(UCLIBC_SOURCE)
	touch $@

uclibc-patched: $(UCLIBC_DIR)/.patched
$(UCLIBC_DIR)/.patched: $(UCLIBC_DIR)/.unpacked
	for i in $(UCLIBC_MAKE_DIR)/$(UCLIBC_VERSION)/*.patch; do \
		$(PATCH_TOOL) $(UCLIBC_DIR) $$i; \
	done
	cp -dpf $(UCLIBC_LOCALE_DATA) $(UCLIBC_DIR)/extra/locale/
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
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/lib
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" \
		oldconfig
	touch $@

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.config
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" headers \
		$(if $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28),install_dev,install_headers)
	# Install the kernel headers to the first stage gcc include dir if necessary
	if [ ! -f $(TARGET_TOOLCHAIN_STAGING_DIR)/include/linux/version.h ] ; then \
	    cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include/ ; \
	    cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/linux $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include/ ; \
	    if [ -d $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic ] ; then \
		cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic \
		$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include/ ; \
	    fi; \
	fi;			
	touch $@

uclibc-menuconfig: $(UCLIBC_DIR)/.config
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" \
		menuconfig && \
	cp -f $^ $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF).$(UCLIBC_VERSION) && \
	touch $^

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured $(gcc_initial)
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		HOSTCC="$(HOSTCC)" \
		all
	touch -c $@

ifeq ($(strip $(FREETZ_BUILD_TOOLCHAIN)),y)
$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		install_runtime install_dev
	# Install the kernel headers to the staging dir if necessary
	if [ ! -f $(TARGET_TOOLCHAIN_STAGING_DIR)/include/linux/version.h ] ; then \
	    cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm $(TARGET_TOOLCHAIN_STAGING_DIR)/include/ ; \
	    cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/linux $(TARGET_TOOLCHAIN_STAGING_DIR)/include/ ; \
	    if [ -d $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic ] ; then \
		cp -pLR $(UCLIBC_KERNEL_HEADERS_DIR)/asm-generic \
		    $(TARGET_TOOLCHAIN_STAGING_DIR)/include/ ; \
	    fi; \
	fi;								    
	# Build the host utils. 
	$(MAKE1) -C $(UCLIBC_DIR)/utils \
		PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		HOSTCC="$(HOSTCC)" \
		hostutils
	install -c $(UCLIBC_DIR)/utils/ldd.host $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ldd
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/ldd $(GNU_TARGET_NAME)-ldd)
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/ldd $(REAL_GNU_TARGET_NAME)-ldd)
	install -c $(UCLIBC_DIR)/utils/ldconfig.host $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ldconfig
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/ldconfig $(GNU_TARGET_NAME)-ldconfig)
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -sf ../$(REAL_GNU_TARGET_NAME)/bin/ldconfig $(REAL_GNU_TARGET_NAME)-ldconfig)
	touch -c $@

$(ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a
	@rm -rf $(ROOT_DIR)/lib
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX="$(shell pwd)/$(ROOT_DIR)" \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		install_runtime
	touch -c $@
else
$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a: $(cross_compiler)
	touch -c $@

$(ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a
	@rm -rf $(ROOT_DIR)/lib
	@mkdir -p $(ROOT_DIR)/lib
	for i in $(UCLIBC_FILES); do \
		cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/$$i $(ROOT_DIR)/lib/$$i; \
	done
	touch -c $@
endif

uclibc-configured: kernel-configured $(UCLIBC_DIR)/.configured

uclibc: $(cross_compiler) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a $(ROOT_DIR)/lib/libc.so.0

uclibc-source: $(DL_DIR)/$(UCLIBC_SOURCE)

uclibc-configured-source: uclibc-source

uclibc-clean:
	-$(MAKE1) -C $(UCLIBC_DIR) clean
	rm -f $(UCLIBC_DIR)/.config

uclibc-dirclean:
	rm -rf $(UCLIBC_DIR)

.PHONY: uclibc-configured uclibc

#############################################################
#
# uClibc for the target
#
#############################################################

$(TARGET_UTILS_DIR)/usr/lib/libc.a: | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
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

$(TARGET_UTILS_DIR)/lib/libc.so.0: | $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_UTILS_DIR) \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		UCLIBC_EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		UCLIBC_EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		install_runtime
	touch -c $@

$(TARGET_UTILS_DIR)/usr/bin/ldd: $(cross_compiler) $(TARGET_UTILS_DIR)/lib/libc.so.0
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_UTILS_DIR) \
		UCLIBC_EXTRA_LDFLAGS="$(TARGET_LDFLAGS)" \
		UCLIBC_EXTRA_CFLAGS="$(TARGET_CFLAGS)" \
		utils install_utils

uclibc_target: cross_compiler uclibc $(TARGET_UTILS_DIR)/usr/lib/libc.a \
		$(TARGET_UTILS_DIR)/lib/libc.so.0 $(TARGET_UTILS_DIR)/usr/bin/ldd

uclibc_target-clean:
	rm -rf $(TARGET_UTILS_DIR)/usr/include $(TARGET_UTILS_DIR)/lib/libc.so.0 \
		$(TARGET_UTILS_DIR)/usr/lib/libc.a $(TARGET_UTILS_DIR)/usr/bin/ldd

uclibc_target-dirclean:
	rm -rf $(TARGET_UTILS_DIR)/usr/include
