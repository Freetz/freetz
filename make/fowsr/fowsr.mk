$(call PKG_INIT_BIN, 1.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-20110904.tar.gz
$(PKG)_SOURCE_MD5:=3dbe93a59d85bf89f9c1d20d54f5e983
$(PKG)_SITE:=http://fowsr.googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/fowsr
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/fowsr

$(PKG)_SCRIPTS:=fowsr.sh pwsweather.sh pywws.sh wunderground.sh xml.sh
$(PKG)_SCRIPTS_DIR:=/usr/bin
$(PKG)_SCRIPTS_BUILD_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DIR)/%)
$(PKG)_SCRIPTS_TARGET_DIR:=$($(PKG)_SCRIPTS:%=$($(PKG)_DEST_DIR)$($(PKG)_SCRIPTS_DIR)/%)

$(PKG)_DEPENDS_ON += libusb

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FOWSR_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_SCRIPTS_BUILD_DIR): $($(PKG_DIR)/.unpacked
	@touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SCRIPTS_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_SCRIPTS_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_SCRIPTS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(FOWSR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(FOWSR_TARGET_BINARY) $(FOWSR_SCRIPTS)

$(PKG_FINISH)
