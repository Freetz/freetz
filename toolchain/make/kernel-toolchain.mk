include $(TOOLCHAIN_DIR)/make/kernel/*/*.mk


kernel-toolchain: $(CROSSTOOL_DIR)/.installed
	@rm -f $(TOOLCHAIN_DIR)/kernel
	@ln -s $(BUILD_DIR)/$(CROSSTOOL_COMPILER)/mipsel-unknown-linux-gnu $(TOOLCHAIN_DIR)/kernel

kernel-toolchain-source: $(CROSSTOOL_DIR)/.unpacked2

kernel-toolchain-clean:

kernel-toolchain-dirclean:
	rm -rf $(CROSSTOOL_DIR)

kernel-toolchain-distclean: kernel-toolchain-dirclean
	rm -rf $(TOOLCHAIN_BUILD_DIR)/$(CROSSTOOL_COMPILER)
	rm -f $(TOOLCHAIN_DIR)/kernel
