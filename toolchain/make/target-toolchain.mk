include $(TOOLCHAIN_DIR)/make/target/*/*.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	CCACHE:=ccache
endif

ifeq ($(strip $(FREETZ_TARGET_TOOLCHAIN)),y)
	TARGETT:=binutils_target gcc_target uclibc_target
endif

TARGET_TOOLCHAIN:=binutils gcc $(CCACHE) $(TARGETT) uclibcxx libtool-host gdb

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@
	@mkdir -p $@/bin
	@mkdir -p $@/lib
	@ln -snf . $(TARGET_TOOLCHAIN_STAGING_DIR)/usr
	@mkdir -p $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)
	@ln -snf ../lib $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/$(REAL_GNU_TARGET_NAME)/lib
	@mkdir -p $@/usr/lib/pkgconfig
	@mkdir -p $@/target-utils

target-toolchain: $(TARGET_TOOLCHAIN_DIR) $(TARGET_TOOLCHAIN_STAGING_DIR) \
			$(TARGET_TOOLCHAIN_SYMLINK_DOT_FILE) \
			kernel-configured uclibc-configured \
			$(TARGET_TOOLCHAIN)

target-toolchain-source: $(TARGET_TOOLCHAIN_DIR) \
	$(UCLIBC_DIR)/.unpacked \
	$(BINUTILS_DIR)/.unpacked \
	$(GCC_DIR)/.unpacked \
	$(CCACHE_DIR)/.unpacked

target-toolchain-clean:
	$(RM) $(UCLIBC_DIR)/.config
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)*
	$(RM) -r $(TARGET_UTILS_DIR)/*
	-$(MAKE) -C $(UCLIBC_DIR) clean
	-$(MAKE) -C $(BINUTILS_DIR) clean
	$(RM) -r $(GCC_BUILD_DIR1)
	$(RM) -r $(GCC_BUILD_DIR2)
	$(RM) -r $(GCC_BUILD_DIR3)
ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(CCACHE_DIR) clean
endif

target-toolchain-dirclean:
	$(RM) -r $(TARGET_TOOLCHAIN_DIR)
