$(call PKG_INIT_BIN,20040226)
$(PKG)_SOURCE:=br2684ctl_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/b/br2684ctl
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION).orig
$(PKG)_BINARY:=$($(PKG)_DIR)/br2684ctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/br2684ctl

$(PKG)_DEPENDS_ON := linux-atm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BR2684CTL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		OPTS="" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_TARGET_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(BR2684CTL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BR2684CTL_TARGET_BINARY)

$(PKG_FINISH)
