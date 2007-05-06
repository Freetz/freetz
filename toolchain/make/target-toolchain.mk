ifeq ($(strip $(DS_TARGET_CCACHE)),y)
TARGET_TOOLCHAIN:=binutils gcc ccache gdb
else
TARGET_TOOLCHAIN:=binutils gcc gdb
endif

include $(TOOLCHAIN_DIR)/make/target/*/*.mk


$(TARGET_TOOLCHAIN_DIR):
	@mkdir -p $@

$(TARGET_TOOLCHAIN_STAGING_DIR):
	@mkdir -p $@
	@mkdir -p $@/lib
	@mkdir -p $@/include
	@mkdir -p $@/$(REAL_GNU_TARGET_NAME)
	@ln -sf ../lib $@/$(REAL_GNU_TARGET_NAME)/lib
#moved from target-toolchain because link is needed for uclibc-build
	@rm -f $(TOOLCHAIN_DIR)/target
	@ln -s $(BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)/$(REAL_GNU_TARGET_NAME) $(TOOLCHAIN_DIR)/target

target-toolchain: $(TARGET_TOOLCHAIN_DIR) $(TARGET_TOOLCHAIN_STAGING_DIR) \
                  kernel-configured uclibc-configured \
                  $(TARGET_TOOLCHAIN)
	

target-toolchain-source: $(TARGET_TOOLCHAIN_DIR) \
	$(UCLIBC_DIR)/.unpacked \
	$(BINUTILS_DIR)/.unpacked \
	$(GCC_DIR)/.unpacked \
	$(CCACHE_DIR)/.unpacked

target-toolchain-clean:
	rm -f $(UCLIBC_DIR)/.config
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(UCLIBC_DIR) clean
	-$(MAKE) -C $(BINUTILS_DIR) clean
	rm -rf $(GCC_BUILD_DIR1)
	rm -rf $(GCC_BUILD_DIR2)
ifeq ($(strip $(DS_TARGET_CCACHE)),y)
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin-ccache/$(REAL_GNU_TARGET_NAME)*
	-$(MAKE) -C $(CCACHE_DIR) clean
endif

target-toolchain-dirclean:
	rm -rf $(TARGET_TOOLCHAIN_DIR)

target-toolchain-distclean: target-toolchain-dirclean
	rm -rf $(TOOLCHAIN_BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)
	rm -f $(TOOLCHAIN_DIR)/target
