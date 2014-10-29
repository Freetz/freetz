$(call PKG_INIT_BIN,1.99)
$(PKG)_SOURCE:=inadyn.source.v$($(PKG)_VERSION).zip
$(PKG)_SOURCE_MD5:=0f2cf9c3ea3482c03e1c42f8480f1c55
$(PKG)_SITE:=http://www.opendns.com/support/ddns_files
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/inadyn.source.v$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/linux/inadyn
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/inadyn-opendns

$(PKG)_DEPENDS_ON += curl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(INADYN_OPENDNS_DIR) \
		CC="$(TARGET_CC)" \
		STRIP="$(TARGET_STRIP)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(INADYN_OPENDNS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(INADYN_OPENDNS_TARGET_BINARY)

$(PKG_FINISH)
