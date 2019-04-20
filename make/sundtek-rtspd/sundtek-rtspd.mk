$(call PKG_INIT_BIN, 0.0)
$(PKG)_SOURCE_DOWNLOAD_NAME:=rtspd
$(PKG)_SOURCE:=$(if $(FREETZ_PACKAGE_SUNDTEK),sundtek-$($(PKG)_SOURCE_DOWNLOAD_NAME)-$(SUNDTEK_ARCH))
$(PKG)_SITE:=http://sundtek.de/media/streamer/$(SUNDTEK_ARCH)

$(PKG)_TARGET_PATH:=/usr/bin/sundtek-$($(PKG)_SOURCE_DOWNLOAD_NAME)

$(if $(FREETZ_PACKAGE_SUNDTEK_RTSPD_FORCE_DOWNLOAD),.PHONY: $(DL_DIR)/$($(PKG)_SOURCE))

define $(PKG)_CUSTOM_UNPACK
	mkdir -p $($(PKG)_DIR)
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH): $(DL_DIR)/$($(PKG)_SOURCE)
	$(INSTALL_BINARY_STRIP)
	@chmod 755 $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_DEST_DIR)$($(PKG)_TARGET_PATH)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) $(SUNDTEK_RTSPD_DEST_DIR)$(SUNDTEK_RTSPD_TARGET_PATH)

$(PKG_FINISH)
