$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=rcapid-cm.tar.gz
$(PKG)_HASH:=ed734e2bd98011edb561b3ee7282ab969d7552c2389661c7057960a2c241b1e5
$(PKG)_SITE:=ftp://ftp.melware.de/capi-utils

$(PKG)_BINARY:=$($(PKG)_DIR)/rcapid
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/rcapid

$(PKG)_DEPENDS_ON += libcapi

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RCAPID_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(RCAPID_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RCAPID_TARGET_BINARY)

$(PKG_FINISH)
