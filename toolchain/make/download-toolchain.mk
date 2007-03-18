KERNEL_TOOLCHAIN_VERSION:=0.1
TARGET_TOOLCHAIN_VERSION:=0.1
TARGET_TOOLCHAIN_SOURCE:=target-toolchain-dsmod-$(TARGET_TOOLCHAIN_VERSION).tar.lzma
KERNEL_TOOLCHAIN_SOURCE:=kernel-toolchain-dsmod-$(KERNEL_TOOLCHAIN_VERSION).tar.lzma
TOOLCHAIN_SITE:=


$(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE):
	wget -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(KERNEL_TOOLCHAIN_SOURCE)

$(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE):
	wget -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(TARGET_TOOLCHAIN_SOURCE)

download-toolchain: $(TOOLCHAIN_DIR)/kernel/.installed $(TOOLCHAIN_DIR)/target/.installed

$(TOOLCHAIN_DIR)/kernel/.installed: $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(TOOLS_DIR)/busybox tar -xaf $(DL_DIR)/$(KERNEL_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	-@ln -s $(BUILD_DIR)/$(CROSSTOOL_COMPILER)/mipsel-unknown-linux-gnu $(TOOLCHAIN_DIR)/kernel
	@touch $@

$(TOOLCHAIN_DIR)/target/.installed: $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) busybox
	mkdir -p $(TOOLCHAIN_DIR)/build
	$(TOOLS_DIR)/busybox tar -xaf $(DL_DIR)/$(TARGET_TOOLCHAIN_SOURCE) -C $(TOOLCHAIN_DIR)/build
	-@ln -s $(BUILD_DIR)/$(TARGET_TOOLCHAIN_COMPILER)/$(REAL_GNU_TARGET_NAME) $(TOOLCHAIN_DIR)/target
	@touch $@

ifeq ($(strip $(DS_DOWNLOAD_TOOLCHAIN)),y)
toolchain-dirclean:
	rm -rf $(TOOLCHAIN_DIR)/kernel
	rm -rf $(TOOLCHAIN_DIR)/target
endif

