include $(TOOLCHAIN_DIR)/make/kernel/binutils/binutils.mk
include $(TOOLCHAIN_DIR)/make/kernel/gcc/gcc.mk
include $(TOOLCHAIN_DIR)/make/kernel/ccache/ccache.mk

KERNEL_TOOLCHAIN:=binutils-kernel gcc-kernel $(if $(FREETZ_TOOLCHAIN_CCACHE),ccache-kernel)

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(KERNEL_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@ $@/bin $@/lib
	@mkdir -p $@/$(REAL_GNU_KERNEL_NAME)
	@ln -snf ../lib $@/$(REAL_GNU_KERNEL_NAME)/lib

kernel-toolchain: $(KERNEL_TOOLCHAIN_DIR) \
	$(KERNEL_TOOLCHAIN_STAGING_DIR) \
	$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) \
	$(KERNEL_TOOLCHAIN)

kernel-toolchain-source: $(KERNEL_TOOLCHAIN_DIR) \
	$(BINUTILS_KERNEL_DIR)/.unpacked \
	$(GCC_KERNEL_DIR)/.unpacked \
	$(CCACHE_KERNEL_DIR)./unpacked

kernel-toolchain-clean: \
	binutils-kernel-uninstall gcc-kernel-uninstall \
	binutils-kernel-clean gcc-kernel-clean ccache-kernel-clean

kernel-toolchain-dirclean: binutils-kernel-dirclean gcc-kernel-dirclean ccache-kernel-dirclean
	$(RM) -r $(KERNEL_TOOLCHAIN_DIR)
