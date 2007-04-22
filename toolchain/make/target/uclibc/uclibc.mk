UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/uclibc
UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_SOURCE:=uClibc-$(UCLIBC_VERSION).tar.bz2
UCLIBC_SOURCE_SITE:=http://www.uclibc.org/downloads
UCLIBC_PACKAGE_VERSION:=0.1
UCLIBC_PACKAGE:=uClibc-$(UCLIBC_VERSION)-dsmod-$(UCLIBC_PACKAGE_VERSION).tar.bz2
UCLIBC_PACKAGE_SITE:=http://dsmod.wirsind.info

$(DL_DIR)/$(UCLIBC_SOURCE):
	wget -P $(DL_DIR) $(UCLIBC_SOURCE_SITE)/$(UCLIBC_SOURCE)

$(DL_DIR)/$(UCLIBC_PACKAGE):
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(UCLIBC_PACKAGE) $(UCLIBC_PACKAGE_SITE)

$(UCLIBC_DIR)/.unpacked: $(DL_DIR)/$(UCLIBC_SOURCE)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(UCLIBC_SOURCE)
	for i in $(UCLIBC_MAKE_DIR)/$(UCLIBC_VERSION)/*.patch; do \
	    patch -d $(UCLIBC_DIR) -p1 < $$i; \
	done
	touch $@

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.unpacked | kernel-configured
	cp $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF).$(AVM_VERSION) $(UCLIBC_DIR)/.config
	sed -i -e 's,^KERNEL_SOURCE=.*,KERNEL_SOURCE=\"$(shell pwd)/$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel/linux\",g' $(UCLIBC_DIR)/.config
	sed -i -e 's,^CROSS=.*,CROSS=$(TARGET_MAKE_PATH)/$(TARGET_CROSS),g' $(UCLIBC_DIR)/Rules.mak
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/lib
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" \
		pregen 
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" \
		install_dev
	touch $@

$(UCLIBC_DIR)/lib/libc.a: $(UCLIBC_DIR)/.configured $(GCC_BUILD_DIR1)/.installed
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		HOSTCC="$(HOSTCC)" \
		all
	touch -c $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a: $(UCLIBC_DIR)/lib/libc.a
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		install_runtime 
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX= \
		DEVEL_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/ \
		install_dev

ifeq ($(strip $(DS_BUILD_TOOLCHAIN)),y)
$(ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a
	$(MAKE) -C $(UCLIBC_DIR) \
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
	
uclibc-utils:
	# Build the host utils.  Need to add an install target...
	$(MAKE) -C $(UCLIBC_DIR)/utils \
		PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		HOSTCC="$(HOSTCC)" \
		hostutils
	touch -c $@
	# Build the utils. 
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR) \
		HOSTCC="$(HOSTCC)" \
		utils
	cp $(UCLIBC_DIR)/utils/ldd.host $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/
	

.PHONY: uclibc-configured uclibc
