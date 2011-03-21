include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/gcc/libgcc.mk
include $(TOOLCHAIN_DIR)/make/target/libtool-host/libtool-host.mk
include $(TOOLCHAIN_DIR)/make/target/gdb/gdb.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	CCACHE:=ccache-kernel ccache
endif

KERNEL_TOOLCHAIN_MD5_mips_3.4.6:=059ee6fda4291e461e4907436a57e25e
KERNEL_TOOLCHAIN_MD5_mips_4.4.5:=2f04367cb1238d591cdfc16ebf1c5665
KERNEL_TOOLCHAIN_MD5_mipsel_3.4.6:=4f03f77fe7764f255da511e74b3073f1
KERNEL_TOOLCHAIN_MD5_mipsel_4.4.5:=7c37b94cb2c2e97b98737296d2d2cf9d
KERNEL_TOOLCHAIN_MD5:=$(KERNEL_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(KERNEL_TOOLCHAIN_GCC_VERSION))

KERNEL_TOOLCHAIN_VERSION:=0.2
KERNEL_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-$(KERNEL_TOOLCHAIN_VERSION)-shared-glibc.tar.lzma

TARGET_TOOLCHAIN_MD5_mips_4.4.5_0.9.29:=4cfba5765128f15e36565a279e289697
TARGET_TOOLCHAIN_MD5_mips_4.4.5_0.9.30.3:=ef5d4fb18208534346f36046dd05bb86
TARGET_TOOLCHAIN_MD5_mips_4.5.2_0.9.31:=89122c133641d6148ca34d7a63dc12e2
TARGET_TOOLCHAIN_MD5_mipsel_4.4.5_0.9.28:=21021079165bc32bcd4afd465b9f1cd0
TARGET_TOOLCHAIN_MD5_mipsel_4.4.5_0.9.29:=c38caf992796cbb0fa1cd602bf2cae87
TARGET_TOOLCHAIN_MD5_mipsel_4.5.2_0.9.31:=30e0a5430c9f68d8d0653d3b25e2a981
TARGET_TOOLCHAIN_MD5:=$(TARGET_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(TARGET_TOOLCHAIN_GCC_VERSION)_$(TARGET_TOOLCHAIN_UCLIBC_VERSION))

TARGET_TOOLCHAIN_VERSION:=0.2
TARGET_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(TARGET_TOOLCHAIN_GCC_VERSION)_uClibc-$(TARGET_TOOLCHAIN_UCLIBC_VERSION)-freetz-$(TARGET_TOOLCHAIN_VERSION)-shared-glibc.tar.lzma

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(KERNEL_TOOLCHAIN_SOURCE) "" $(KERNEL_TOOLCHAIN_MD5)

$(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(TARGET_TOOLCHAIN_SOURCE) "" $(TARGET_TOOLCHAIN_MD5)

download-toolchain: $(KERNEL_CROSS_COMPILER) kernel-configured \
			$(TARGET_CROSS_COMPILER) target-toolchain-kernel-headers \
			$(TARGET_SPECIFIC_ROOT_DIR)/lib/libc.so.0 $(TARGET_SPECIFIC_ROOT_DIR)/lib/libgcc_s.so.1 \
			$(CCACHE) uclibcxx libtool-host

gcc-kernel: $(KERNEL_CROSS_COMPILER)
$(KERNEL_CROSS_COMPILER): $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) | \
		$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)/$(KERNEL_TOOLCHAIN_COMPILER)
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	@touch $@

gcc: $(TARGET_CROSS_COMPILER)
$(TARGET_CROSS_COMPILER): $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) | \
		$(TARGET_TOOLCHAIN_SYMLINK_DOT_FILE) $(TOOLS_DIR)/busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(RM) -r $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	$(TOOLS_DIR)/busybox tar $(VERBOSE) -xaf $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	@touch $@

download-toolchain-clean:

download-toolchain-dirclean: kernel-toolchain-dirclean target-toolchain-dirclean

download-toolchain-distclean: kernel-toolchain-distclean target-toolchain-distclean

kernel-toolchain-dirclean:

target-toolchain-dirclean:

.PHONY: gcc-kernel gcc
