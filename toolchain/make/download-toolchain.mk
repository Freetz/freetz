TOOLCHAIN_VERSION:=0.1
TOOLCHAIN_SOURCE:=toolchain-dsmod-$(TOOLCHAIN_VERSION).tar.lzma
TOOLCHAIN_SITE:=http://www.eiband.info/dsmod

$(DL_DIR)/$(TOOLCHAIN_SOURCE):
	wget -P $(DL_DIR) $(TOOLCHAIN_SITE)/$(TOOLCHAIN_SOURCE)

download-toolchain: $(TOOLCHAIN_DIR)/.installed

$(TOOLCHAIN_DIR)/.installed: $(DL_DIR)/$(TOOLCHAIN_SOURCE) lzma
	@(cd $(TOOLCHAIN_DIR); \
	../$(TOOLS_DIR)/lzma d ../$(DL_DIR)/$(TOOLCHAIN_SOURCE) -so |tar x)
	@touch $@

ifeq ($(strip $(DS_DOWNLOAD_TOOLCHAIN)),y)
toolchain-distclean:
	rm -rf $(TOOLCHAIN_DIR)/kernel
	rm -rf $(TOOLCHAIN_DIR)/target
	rm -rf $(TOOLCHAIN_DIR)/.installed
endif

