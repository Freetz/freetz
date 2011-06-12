include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/ccache/ccache.mk
include $(TOOLCHAIN_DIR)/make/target/gcc/libgcc.mk
include $(TOOLCHAIN_DIR)/make/target/libtool-host/libtool-host.mk
include $(TOOLCHAIN_DIR)/make/target/uclibc/uclibc.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
	CCACHE:=ccache-kernel ccache
endif

KERNEL_TOOLCHAIN_MD5_mips_3.4.6:=0694eb3726ec9795bdaaa22015e6ff69
KERNEL_TOOLCHAIN_MD5_mips_4.4.6:=1c132267eaef4e2e46dba9d08a343677
KERNEL_TOOLCHAIN_MD5_mipsel_3.4.6:=93d14675e31aeb46c1188d41aa17c8a6
KERNEL_TOOLCHAIN_MD5_mipsel_4.4.6:=3c692e4ad2cf9063a25d207ea33d15c8
KERNEL_TOOLCHAIN_MD5:=$(KERNEL_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(KERNEL_TOOLCHAIN_GCC_VERSION))

KERNEL_TOOLCHAIN_VERSION:=0.3
KERNEL_TOOLCHAIN_SOURCE:=$(TARGET_ARCH)_gcc-$(KERNEL_TOOLCHAIN_GCC_VERSION)-freetz-$(KERNEL_TOOLCHAIN_VERSION)-shared-glibc.tar.lzma

TARGET_TOOLCHAIN_MD5_mips_4.4.6_0.9.29:=d571991596cd71be8280a66f1588d3c8
TARGET_TOOLCHAIN_MD5_mips_4.4.6_0.9.30.3:=1d00742ec07727c752b270fd19da4d02
TARGET_TOOLCHAIN_MD5_mips_4.5.3_0.9.31:=7c8b91a153dfe43e9668e85032fe2283
TARGET_TOOLCHAIN_MD5_mipsel_4.4.6_0.9.28:=6d07a7989dcbdaa7eec909d2d48e99ff
TARGET_TOOLCHAIN_MD5_mipsel_4.4.6_0.9.29:=b02d1a07d85887f75882fb0f1717f83f
TARGET_TOOLCHAIN_MD5_mipsel_4.5.3_0.9.31:=0422902593ba3496edd3347f646844ff
TARGET_TOOLCHAIN_MD5:=$(TARGET_TOOLCHAIN_MD5_$(TARGET_ARCH)_$(TARGET_TOOLCHAIN_GCC_VERSION)_$(TARGET_TOOLCHAIN_UCLIBC_VERSION))

TARGET_TOOLCHAIN_VERSION:=0.3
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
			$(CCACHE) uclibcxx libtool-host $(if $(FREETZ_PACKAGE_GDB_HOST),gdbhost)

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
