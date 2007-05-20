ifeq ($(DS_BUILD_TOOLCHAIN),y)

UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/uclibc
UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_SOURCE:=uClibc-$(UCLIBC_VERSION).tar.bz2
UCLIBC_SOURCE_SITE:=http://www.uclibc.org/downloads
UCLIBC_PACKAGE_VERSION:=0.1
UCLIBC_PACKAGE:=uClibc-$(UCLIBC_VERSION)-dsmod-$(UCLIBC_PACKAGE_VERSION).tar.bz2
UCLIBC_PACKAGE_SITE:=http://dsmod.wirsind.info
LINUX_HEADERS_DIR:=$(shell pwd)/$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel/linux

$(DL_DIR)/$(UCLIBC_SOURCE):
	mkdir -p $(DL_DIR)
	wget -P $(DL_DIR) $(UCLIBC_SOURCE_SITE)/$(UCLIBC_SOURCE)

$(DL_DIR)/$(UCLIBC_PACKAGE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(UCLIBC_PACKAGE) $(UCLIBC_PACKAGE_SITE)

$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE)
	mkdir -p $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(UCLIBC_SOURCE)
	for i in $(UCLIBC_MAKE_DIR)/$(UCLIBC_VERSION)/*.patch; do \
	    patch -d $(UCLIBC_DIR) -p1 < $$i; \
	done
	touch $@

$(UCLIBC_DIR)/.config: $(UCLIBC_DIR)/.unpacked | kernel-configured
	cp $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF).$(AVM_VERSION) $(UCLIBC_DIR)/.config
	$(SED) -i -e 's,^KERNEL_SOURCE=.*,KERNEL_SOURCE=\"$(LINUX_HEADERS_DIR)\",g' $(UCLIBC_DIR)/.config
	$(SED) -i -e 's,^CROSS=.*,CROSS=$(TARGET_MAKE_PATH)/$(TARGET_CROSS),g' $(UCLIBC_DIR)/Rules.mak
ifeq ($(DS_TARGET_LFS),y)
	$(SED) 's,.*UCLIBC_HAS_LFS.*,UCLIBC_HAS_LFS=y,g' $(UCLIBC_DIR)/.config
else
	$(SED) 's,.*UCLIBC_HAS_LFS.*,UCLIBC_HAS_LFS=n,g' $(UCLIBC_DIR)/.config
	$(SED) '/.*UCLIBC_HAS_FOPEN_LARGEFILE_MODE.*/d' $(UCLIBC_DIR)/.config
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

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.config
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" \
		pregen install_dev
	# Install the kernel headers to the first stage gcc include dir if necessary
	if [ ! -f $(TARGET_TOOLCHAIN_STAGING_DIR)/include/linux/version.h ] ; then \
	    cp -pLR $(LINUX_HEADERS_DIR)/include/asm $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include/ ; \
	    cp -pLR $(LINUX_HEADERS_DIR)/include/linux $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include/ ; \
	    if [ -d $(LINUX_HEADERS_DIR)/include/asm-generic ] ; then \
		cp -pLR $(LINUX_HEADERS_DIR)/include/asm-generic \
		$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include/ ; \
	    fi; \
	fi;			
	touch $@

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		HOSTCC="$(HOSTCC)" \
		all
	touch -c $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		install_runtime install_dev
	# Install the kernel headers to the staging dir if necessary
	if [ ! -f $(TARGET_TOOLCHAIN_STAGING_DIR)/include/linux/version.h ] ; then \
	    cp -pLR $(LINUX_HEADERS_DIR)/include/asm $(TARGET_TOOLCHAIN_STAGING_DIR)/include/ ; \
	    cp -pLR $(LINUX_HEADERS_DIR)/include/linux $(TARGET_TOOLCHAIN_STAGING_DIR)/include/ ; \
	    if [ -d $(LINUX_HEADERS_DIR)/include/asm-generic ] ; then \
		cp -pLR $(LINUX_HEADERS_DIR)/include/asm-generic \
		    $(TARGET_TOOLCHAIN_STAGING_DIR)/include/ ; \
	    fi; \
	fi;								    
	# Build the host utils.  Need to add an install target...
	$(MAKE1) -C $(UCLIBC_DIR)/utils \
		PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		HOSTCC="$(HOSTCC)" \
		hostutils
	install -c $(UCLIBC_DIR)/utils/ldd.host $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ldd
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -s ../$(REAL_GNU_TARGET_NAME)/bin/ldd $(GNU_TARGET_NAME)-ldd)
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -s ../$(REAL_GNU_TARGET_NAME)/bin/ldd $(REAL_GNU_TARGET_NAME)-ldd)
	install -c $(UCLIBC_DIR)/utils/ldconfig.host $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/bin/ldconfig
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -s ../$(REAL_GNU_TARGET_NAME)/bin/ldconfig $(GNU_TARGET_NAME)-ldconfig)
	(cd $(TARGET_TOOLCHAIN_STAGING_DIR)/bin; ln -s ../$(REAL_GNU_TARGET_NAME)/bin/ldconfig $(REAL_GNU_TARGET_NAME)-ldconfig)
	touch -c $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a

ifeq ($(strip $(DS_BUILD_TOOLCHAIN)),y)
$(ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX="$(shell pwd)/$(ROOT_DIR)/" \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		install_runtime
	touch -c $@
else
$(ROOT_DIR)/lib/libc.so.0: $(DL_DIR)/$(UCLIBC_PACKAGE)
	tar -C $(ROOT_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(UCLIBC_PACKAGE)
	touch -c $@
endif

uclibc-configured: $(UCLIBC_DIR)/.configured

uclibc:	$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a \
	$(ROOT_DIR)/lib/libc.so.0

uclibc-target-utils: $(ROOT_DIR)/usr/bin/ldd

$(ROOT_DIR)/usr/bin/ldd:
	# Build the utils. 
	$(MAKE1) -C $(UCLIBC_DIR) \
		PREFIX=$(shell pwd)/$(ROOT_DIR) utils install_utils
	mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/target_utils
	install -c $(ROOT_DIR)/usr/bin/ldd \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/$(REAL_GNU_TARGET_NAME)/target_utils/ldd
	$(TARGET_STRIP) $(ROOT_DIR)/usr/bin/ldd
	touch -c $(ROOT_DIR)/usr/bin/ldd	    

.PHONY: uclibc-configured uclibc

endif
