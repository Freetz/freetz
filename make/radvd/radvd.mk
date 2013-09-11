$(call PKG_INIT_BIN, 1.9.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=14b025bdcec77ea7278cd8ee2a32af3f81d26f4d
$(PKG)_SITE:=http://www.litech.org/radvd/dist

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

$(PKG)_DEPENDS_ON := libdaemon

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RADVD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $($(PKG)_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RADVD_TARGET_BINARY)

$(PKG_FINISH)
