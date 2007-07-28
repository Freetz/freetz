UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/uclibc
UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_SOURCE:=uClibc-$(UCLIBC_VERSION).tar.bz2
UCLIBC_SOURCE_SITE:=http://www.uclibc.org/downloads
UCLIBC_KERNEL_SOURCE_DIR:=$(KERNEL_SOURCE_DIR)
UCLIBC_KERNEL_HEADERS_DIR:=$(KERNEL_HEADERS_DIR)
UCLIBC_LDD_BINARY:=$(UCLIBC_DIR)/utils/ldd
UCLIBC_LDD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/target_utils/ldd
UCLIBC_TARGET_LDD_BINARY:=$(ROOT_DIR)/usr/bin/ldd

$(DL_DIR)/$(UCLIBC_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(UCLIBC_SOURCE_SITE)/$(UCLIBC_SOURCE)

uclibc-unpacked: $(UCLIBC_DIR)/.unpacked
$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(UCLIBC_SOURCE)
	for i in $(UCLIBC_MAKE_DIR)/$(UCLIBC_VERSION)/*.patch; do \
	    $(PATCH_TOOL) $(UCLIBC_DIR) $$i 1; \
	done
	touch $@

$(UCLIBC_DIR)/.config: $(UCLIBC_DIR)/.unpacked
	cp $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF) $(UCLIBC_DIR)/.config
	$(SED) -i -e 's,^KERNEL_SOURCE=.*,KERNEL_SOURCE=\"$(shell pwd)/$(UCLIBC_KERNEL_SOURCE_DIR)\",g' $(UCLIBC_DIR)/.config
	$(SED) -i -e 's,^CROSS=.*,CROSS=$(TARGET_MAKE_PATH)/$(TARGET_CROSS),g' $(UCLIBC_DIR)/Rules.mak
ifeq ($(strip $(DS_TARGET_LFS)),y)
	$(SED) -i -e 's,.*UCLIBC_HAS_LFS.*,UCLIBC_HAS_LFS=y,g' $(UCLIBC_DIR)/.config
else
	$(SED) -i -e 's,.*UCLIBC_HAS_LFS.*,# UCLIBC_HAS_LFS is not set,g' $(UCLIBC_DIR)/.config
	$(SED) -i -e '/.*UCLIBC_HAS_FOPEN_LARGEFILE_MODE.*/d' $(UCLIBC_DIR)/.config
	echo "# UCLIBC_HAS_FOPEN_LARGEFILE_MODE is not set" >> $(UCLIBC_DIR)/.config
endif
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
		HOSTCC="$(HOSTCC)" \
		pregen install_dev
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
	cp -f $^ $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF) && \
	touch $^

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		HOSTCC="$(HOSTCC)" \
		all
	touch -c $@

ifeq ($(strip $(DS_BUILD_TOOLCHAIN)),y)
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
	# Build the host utils.  Need to add an install target...
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
	touch -c $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a

$(ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX="$(shell pwd)/$(ROOT_DIR)/" \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		install_runtime
	touch -c $@
else
$(TARGET_MAKE_PATH)/../lib/libc.a: $(TOOLCHAIN_DIR)/target/.installed
	touch -c $@

$(ROOT_DIR)/lib/libc.so.0: $(TARGET_MAKE_PATH)/../lib/libc.a
	for i in $(UCLIBC_FILES); do \
		cp -a $(TARGET_MAKE_PATH)/../lib/$$i $(ROOT_DIR)/lib/$$i; \
	done
	touch -c $@
endif

uclibc-configured: kernel-configured $(UCLIBC_DIR)/.configured

uclibc: $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-gcc $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a $(ROOT_DIR)/lib/libc.so.0

uclibc-source: $(DL_DIR)/$(UCLIBC_SOURCE)

uclibc-configured-source: uclibc-source

uclibc-clean:
	-$(MAKE1) -C $(UCLIBC_DIR) clean
	rm -f $(UCLIBC_DIR)/.config

uclibc-dirclean:
	rm -rf $(UCLIBC_DIR)

uclibc-target-utils: $(UCLIBC_TARGET_LDD_BINARY)

$(UCLIBC_LDD_BINARY):
	$(MAKE1) -C $(UCLIBC_DIR) utils

$(UCLIBC_LDD_STAGING_BINARY): $(UCLIBC_LDD_BINARY)
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/target_utils
	cp $^ $@

$(UCLIBC_TARGET_LDD_BINARY): $(UCLIBC_LDD_STAGING_BINARY)
	$(INSTALL_BINARY_STRIP)

uclibc-target-utils-clean:
	rm -f $(UCLIBC_TARGET_LDD_BINARY)

.PHONY: uclibc-configured uclibc
	