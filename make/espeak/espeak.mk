$(call PKG_INIT_BIN, 1.40.02)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-source.zip
$(PKG)_SOURCE_MD5:=708954b44c526e8174df8b88a6382738
$(PKG)_SITE:=@SF/espeak
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)-source
$(PKG)_BINARY:=$($(PKG)_DIR)/src/speak
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/speak

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ESPEAK_DIR)/src \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CFLAGS)" \
		LIBS1="-lm"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
# we have declared FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES as makefile subopt,
# so it's ok to copy the files here and depend on $($(PKG)_BINARY) only
ifeq ($(strip $(FREETZ_PACKAGE_ESPEAK_ALL_LANGUAGES)),y)
	cp -ar $(ESPEAK_DIR)/espeak-data $(ESPEAK_DEST_DIR)/usr/share/
endif
	find $(ESPEAK_DEST_DIR)/usr/share/ -type f -exec chmod 644 {} \+

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ESPEAK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(ESPEAK_TARGET_BINARY)

$(PKG_FINISH)
