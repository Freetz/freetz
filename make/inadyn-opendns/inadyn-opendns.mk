$(call PKG_INIT_BIN,1.99)
$(PKG)_SOURCE:=inadyn.source.v$($(PKG)_VERSION).zip
$(PKG)_HASH:=0360fbe8fd4bd184d015d577361ef2a93226648a2bb7b60546b385025eceaf88
$(PKG)_SITE:=http://www.opendns.com/support/ddns_files

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
