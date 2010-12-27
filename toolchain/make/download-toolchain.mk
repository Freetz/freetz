include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/gcc/libgcc.mk
include $(TOOLCHAIN_DIR)/make/target/libtool-host/libtool-host.mk
include $(TOOLCHAIN_DIR)/make/target/gdb/gdb.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	CCACHE:=ccache-kernel ccache
endif

KERNEL_TOOLCHAIN_MD5_mips_3.4.6:=ec5820105764301de915183b712f8324
KERNEL_TOOLCHAIN_MD5_mips_4.4.5:=ae1994e4558da6800d81c851e56aaf32
KERNEL_TOOLCHAIN_MD5_mipsel_3.4.6:=7e640ff62bffa0e234fed27c202c53a0
KERNEL_TOOLCHAIN_MD5:=$(KERNEL_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(KERNEL_TOOLCHAIN_GCC_VERSION))

KERNEL_TOOLCHAIN_VERSION:=0.1
KERNEL_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-$(KERNEL_TOOLCHAIN_VERSION).tar.lzma

TARGET_TOOLCHAIN_MD5_mips_4.4.5_0.9.29:=b40dd51ca325a15bc0c3eab8dc33e6ed
TARGET_TOOLCHAIN_MD5_mips_4.4.5_0.9.30.3:=86b2e8e511a55df95cf11a0e9aeed2e2
TARGET_TOOLCHAIN_MD5_mipsel_4.4.5_0.9.28:=31d29c580c82f939392227096abfba0b
TARGET_TOOLCHAIN_MD5_mipsel_4.4.5_0.9.29:=f93fe7009d65b948fd6c9dae6f3d489e
TARGET_TOOLCHAIN_MD5:=$(TARGET_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(TARGET_TOOLCHAIN_GCC_VERSION)_$(TARGET_TOOLCHAIN_UCLIBC_VERSION))

TARGET_TOOLCHAIN_VERSION:=0.1
TARGET_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(TARGET_TOOLCHAIN_GCC_VERSION)_uClibc-$(TARGET_TOOLCHAIN_UCLIBC_VERSION)-$(TARGET_TOOLCHAIN_VERSION).tar.lzma

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
