TARGET_TOOLCHAIN_PREFIX=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr
TARGET_TOOLCHAIN_DEVEL_SYSROOT=$(TARGET_TOOLCHAIN_DIR)/$(UCLIBC_DEVEL_SUBDIR)/

TARGET_TOOLCHAIN_PREFIX-gcc-final-phase=$(TARGET_TOOLCHAIN_STAGING_DIR)
# NB: in order the toolchain to be relocatable this must be a subdir of TARGET_TOOLCHAIN_PREFIX-gcc-final-phase
# TODO: modify gcc, so that we don't need this hack
TARGET_TOOLCHAIN_SYSROOT=$(TARGET_TOOLCHAIN_PREFIX-gcc-final-phase)/usr/

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
	@ln -snf . $@/usr
	@mkdir -p $@/usr/$(REAL_GNU_TARGET_NAME)
	@ln -snf ../lib $@/usr/$(REAL_GNU_TARGET_NAME)/lib
	@ln -snf ../include $@/usr/$(REAL_GNU_TARGET_NAME)/include
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
