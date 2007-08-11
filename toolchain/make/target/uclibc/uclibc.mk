ifeq ($(AVM_VERSION),04.01)
UCLIBC_SOURCE:=$(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/GPL/base-src-55.tar.gz
endif

UCLIBC_VERSION:=$(TARGET_TOOLCHAIN_UCLIBC_VERSION)
UCLIBC_DIR:=$(TARGET_TOOLCHAIN_DIR)/uClibc-$(UCLIBC_VERSION)
UCLIBC_MAKE_DIR:=$(TOOLCHAIN_DIR)/make/target/uclibc
UCLIBC_BASE_BUILD_DIR:=base_ohio-8mb_build


$(UCLIBC_DIR)/.unpacked: $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/.unpacked
	rm -rf $(UCLIBC_DIR)
ifeq ($(AVM_VERSION),04.01)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xzf $(UCLIBC_SOURCE) \
		'$(UCLIBC_BASE_BUILD_DIR)/uClibc-$(UCLIBC_VERSION)/*'
	mv $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_BASE_BUILD_DIR)/uClibc-$(UCLIBC_VERSION) $(UCLIBC_DIR)
	rm -rf $(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_BASE_BUILD_DIR)
else
	cp -a $(SOURCE_DIR)/avm-gpl-$(AVM_VERSION)/fritzbox_opensrc/$(UCLIBC_BASE_BUILD_DIR)/uClibc-$(UCLIBC_VERSION) $(UCLIBC_DIR)
endif
	touch $@

$(UCLIBC_DIR)/.configured: $(UCLIBC_DIR)/.unpacked | kernel-configured
	cp $(TOOLCHAIN_DIR)/make/target/uclibc/Config.$(TARGET_TOOLCHAIN_UCLIBC_REF).$(AVM_VERSION) $(UCLIBC_DIR)/.config
	sed -i -e 's,^KERNEL_SOURCE=.*,KERNEL_SOURCE=\"$(shell pwd)/$(SOURCE_DIR)/ref-$(KERNEL_REF)-$(AVM_VERSION)/kernel/linux\",g' $(UCLIBC_DIR)/.config
ifeq ($(strip $(DS_TARGET_LFS)),y)
	sed -i -e 's,^.*UCLIBC_HAS_LFS.*,UCLIBC_HAS_LFS=y,g' $(UCLIBC_DIR)/.config
else
	sed -i -e 's,^.*UCLIBC_HAS_LFS.*,UCLIBC_HAS_LFS=n,g' $(UCLIBC_DIR)/.config
endif
	sed -i -e 's,^CROSS=.*,CROSS=$(KERNEL_MAKE_PATH)/$(KERNEL_CROSS),g' $(UCLIBC_DIR)/Rules.mak
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/include
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/usr/lib
	mkdir -p $(TARGET_TOOLCHAIN_DIR)/uClibc_dev/lib
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=$(TARGET_TOOLCHAIN_DIR)/uClibc_dev/ \
		HOSTCC="$(HOSTCC)" \
		pregen install_dev
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
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)/" \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=/ \
		install_runtime
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX="$(TARGET_TOOLCHAIN_STAGING_DIR)/" \
		DEVEL_PREFIX=/ \
		RUNTIME_PREFIX=../ \
		install_dev
	touch -c $@

$(ROOT_DIR)/lib/libc.so.0: $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a
	$(MAKE) -C $(UCLIBC_DIR) \
		PREFIX="$(shell pwd)/$(ROOT_DIR)/" \
		DEVEL_PREFIX=/usr/ \
		RUNTIME_PREFIX=/ \
		install_runtime
	touch -c $@

uclibc-configured: $(UCLIBC_DIR)/.configured

uclibc:	$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libc.a \
	$(ROOT_DIR)/lib/libc.so.0

.PHONY: uclibc-configured uclibc
