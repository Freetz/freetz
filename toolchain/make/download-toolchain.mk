#include this stuff only when DS_DOWNLOAD_TOOLCHAIN is selected
ifeq ($(strip $(DS_DOWNLOAD_TOOLCHAIN)),y)

KERNEL_TOOLCHAIN_VERSION:=0.1
TARGET_TOOLCHAIN_VERSION:=0.4
TARGET_TOOLCHAIN_SOURCE:=target-toolchain-dsmod-$(TARGET_TOOLCHAIN_VERSION).tar.lzma
KERNEL_TOOLCHAIN_SOURCE:=kernel-toolchain-dsmod-$(KERNEL_TOOLCHAIN_VERSION).tar.lzma
TOOLCHAIN_SITE:=http://dsmod.wirsind.info

$(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(KERNEL_TOOLCHAIN_SOURCE) $(TOOLCHAIN_SITE)

$(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TARGET_TOOLCHAIN_SOURCE) $(TOOLCHAIN_SITE)

download-toolchain: $(TOOLCHAIN_DIR)/kernel/.installed $(TOOLCHAIN_DIR)/target/.installed \
						$(ROOT_DIR)/lib/libc.so.0 $(ROOT_DIR)/lib/libgcc_s.so.1

$(TOOLCHAIN_DIR)/kernel/.installed: $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	rm -rf $(TOOLCHAIN_DIR)/kernel
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	-@ln -s $(BUILD_DIR)/gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-glibc-$(KERNEL_TOOLCHAIN_GLIBC_VERSION)/mipsel-unknown-linux-gnu $(TOOLCHAIN_DIR)/kernel
	@touch $@

$(TOOLCHAIN_DIR)/target/.installed: $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	rm -rf $(TOOLCHAIN_DIR)/target
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	-@ln -s $(BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)/$(REAL_GNU_TARGET_NAME) $(TOOLCHAIN_DIR)/target
	@touch $@

toolchain-distclean:
	rm -rf $(TOOLCHAIN_DIR)/build
	rm -rf $(TOOLCHAIN_DIR)/kernel
	rm -rf $(TOOLCHAIN_DIR)/target

endif

