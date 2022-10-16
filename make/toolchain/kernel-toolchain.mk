include $(MAKE_DIR)/toolchain/kernel/binutils/binutils.mk
include $(MAKE_DIR)/toolchain/kernel/gcc/gcc.mk
include $(MAKE_DIR)/toolchain/kernel/ccache/ccache.mk

KERNEL_TOOLCHAIN:=binutils-kernel gcc-kernel $(if $(FREETZ_TOOLCHAIN_CCACHE),ccache-kernel)

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(KERNEL_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@ $@/bin $@/lib
	@mkdir -p $@/$(REAL_GNU_KERNEL_NAME)
	@ln -snf ../lib $@/$(REAL_GNU_KERNEL_NAME)/lib

kernel-toolchain: \
	$(KERNEL_TOOLCHAIN_STAGING_DIR) \
	$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) \
	$(KERNEL_TOOLCHAIN) \
	| $(KERNEL_TOOLCHAIN_DIR)

kernel-toolchain-unpacked: \
	binutils-kernel-unpacked \
	gcc-kernel-unpacked \
	$(if $(FREETZ_TOOLCHAIN_CCACHE),ccache-kernel-unpacked) \
	| $(KERNEL_TOOLCHAIN_DIR)

kernel-toolchain-clean: \
	binutils-kernel-uninstall gcc-kernel-uninstall \
	binutils-kernel-clean gcc-kernel-clean

kernel-toolchain-dirclean: binutils-kernel-dirclean gcc-kernel-dirclean
	$(RM) -r $(KERNEL_TOOLCHAIN_DIR)

.PHONY: kernel-toolchain kernel-toolchain-unpacked kernel-toolchain-clean kernel-toolchain-dirclean
