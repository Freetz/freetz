$(call PKG_INIT_BIN, 1.40.02)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-source.zip
$(PKG)_SITE:=@SF/espeak
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)-source
$(PKG)_BINARY:=$($(PKG)_DIR)/src/speak
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/speak
$(PKG)_SOURCE_MD5:=708954b44c526e8174df8b88a6382738 

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $(ESPEAK_DIR)/.configured
	$(SUBMAKE) -C $(ESPEAK_DIR)/src \
		CXX="mipsel-linux-g++-uc" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LIBS1="-lm"

$(ESPEAK_TARGET_BINARY): $(ESPEAK_BINARY) 
	$(INSTALL_BINARY_STRIP)
	$(if $(FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES),\
		cp -ar $(ESPEAK_DIR)/espeak-data $(ESPEAK_DEST_DIR)/usr/share/,)

$(pkg):

$(pkg)-precompiled: $(ESPEAK_TARGET_BINARY) 

$(pkg)-clean:
	-$(SUBMAKE) -C $(ESPEAK_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(ESPEAK_TARGET_BINARY)

$(PKG_FINISH)
