include $(TOOLCHAIN_DIR)/make/kernel/*/*.mk

ifeq ($(strip $(FREETZ_TARGET_CCACHE)),y)
        CCACHE:=ccache-kernel
endif

KERNEL_TOOLCHAIN:=binutils-kernel gcc-kernel $(CCACHE)

$(KERNEL_TOOLCHAIN_DIR):
	@mkdir -p $@

$(KERNEL_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@
	@mkdir -p $@/bin
	@mkdir -p $@/lib
	@mkdir -p $@/$(REAL_GNU_KERNEL_NAME)
	@ln -snf ../lib $@/$(REAL_GNU_KERNEL_NAME)/lib

kernel-toolchain: $(KERNEL_TOOLCHAIN_DIR) $(KERNEL_TOOLCHAIN_STAGING_DIR) \
			$(KERNEL_TOOLCHAIN_SYMLINK_DOT_FILE) $(KERNEL_TOOLCHAIN)

kernel-toolchain-source: $(KERNEL_TOOLCHAIN_DIR) \
	$(BINUTILS_KERNEL_DIR)/.unpacked \
	$(GCC_KERNEL_DIR)/.unpacked \
	$(CCACHE_KERNEL_DIR)./unpacked

kernel-toolchain-clean:
	rm -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_KERNEL_NAME)*
	-$(MAKE) -C $(BINUTILS_KERNEL_DIR) clean
	rm -rf $(GCC_KERNELBUILD_DIR1)
	rm -rf $(GCC_KERNELBUILD_DIR2)
ifeq ($(strip $(FREETZ_KERNEL_CCACHE)),y)
	rm -f $(KERNEL_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(CCACHE_KERNEL_DIR) clean
endif

kernel-toolchain-dirclean:
	rm -rf $(KERNEL_TOOLCHAIN_DIR)
