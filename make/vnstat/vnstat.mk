$(call PKG_INIT_BIN, 1.9)
$(PKG)_SOURCE:=vnstat-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://humdi.net/vnstat
$(PKG)_BINARY:=$($(PKG)_DIR)/src/vnstat
$(PKG)_DAEMON:=$($(PKG)_DIR)/src/vnstatd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/vnstat
$(PKG)_TARGET_DAEMON:=$($(PKG)_DEST_DIR)/usr/bin/vnstatd
$(PKG)_SOURCE_MD5:=ebaf8352fa3674faea2fe2ce1001a38d

VNSTAT_LIBS := -lm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY) $($(PKG)_DAEMON): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(VNSTAT_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)" \
	LIBS="$(VNSTAT_LIBS)" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_DAEMON): $($(PKG)_DAEMON)
	$(INSTALL_BINARY_STRIP)

$(pkg):
ifeq ($(strip $(FREETZ_PACKAGE_VNSTAT_DAEMON)),y)
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_DAEMON)
else
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(pkg)-clean-daemon
endif

$(pkg)-clean-daemon:
	$(RM) $(VNSTAT_TARGET_DAEMON)

$(pkg)-clean:
	-$(MAKE) -C $(VNSTAT_DIR) clean
	$(RM) $(VNSTAT_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(VNSTAT_TARGET_BINARY) \
		 $(VNSTAT_TARGET_DAEMON)

$(PKG_FINISH)