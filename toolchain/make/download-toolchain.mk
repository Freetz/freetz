include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/gcc/libgcc.mk
include $(TOOLCHAIN_DIR)/make/target/gdb/gdb.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	CCACHE:=ccache-kernel ccache
endif

KERNEL_TOOLCHAIN_VERSION:=0.3
KERNEL_TOOLCHAIN_SOURCE:=gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-freetz-$(KERNEL_TOOLCHAIN_VERSION).tar.lzma
KERNEL_TOOLCHAIN_MD5SUM:=79395130ec54cb42807fcd79628c8597

ifeq ($(strip $(TARGET_TOOLCHAIN_UCLIBC_VERSION)),0.9.28)
TARGET_TOOLCHAIN_VERSION:=0.1
TARGET_TOOLCHAIN_MD5SUM:=be9bde22544f9a1341ef94144f2c175e
else
TARGET_TOOLCHAIN_VERSION:=0.2
TARGET_TOOLCHAIN_MD5SUM:=dbdf87d13ca40bc59d056ee90d4d7976
endif
TARGET_TOOLCHAIN_SOURCE:=gcc-$(TARGET_TOOLCHAIN_GCC_VERSION)-uclibc-$(TARGET_TOOLCHAIN_UCLIBC_VERSION)-freetz-$(TARGET_TOOLCHAIN_VERSION).tar.lzma

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(KERNEL_TOOLCHAIN_SOURCE) "" $(KERNEL_TOOLCHAIN_MD5SUM)

$(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TARGET_TOOLCHAIN_SOURCE) "" $(TARGET_TOOLCHAIN_MD5SUM)

download-toolchain: $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc kernel-configured \
			$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc \
			$(ROOT_DIR)/lib/libc.so.0 $(ROOT_DIR)/lib/libgcc_s.so.1 \
			$(CCACHE)

$(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)-gcc: $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) | \
		$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) $(TOOLCHAIN_DIR)/kernel
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	-@ln -s $(BUILD_DIR)/gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)/mipsel-unknown-linux-gnu $(TOOLCHAIN_DIR)/kernel
	@touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-gcc: $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) | \
		$(TARGET_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) $(TOOLCHAIN_DIR)/target
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	-@ln -s $(BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)/$(REAL_GNU_TARGET_NAME) $(TOOLCHAIN_DIR)/target
	@touch $@

download-toolchain-clean:

download-toolchain-dirclean: kernel-toolchain-dirclean target-toolchain-dirclean

download-toolchain-distclean: kernel-toolchain-distclean target-toolchain-distclean

kernel-toolchain-dirclean:
	rm -rf $(TOOLCHAIN_BUILD_DIR)/$(KERNEL_TOOLCHAIN_COMPILER)
	rm -f $(TOOLCHAIN_DIR)/kernel

target-toolchain-dirclean:
	rm -rf $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	rm -f $(TOOLCHAIN_DIR)/target

kernel-toolchain-distclean: kernel-toolchain-dirclean

target-toolchain-distclean: target-toolchain-dirclean

