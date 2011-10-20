$(call PKG_INIT_BIN, 1.8.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.litech.org/radvd/dist
$(PKG)_SOURCE_MD5:=73d533b7b20f5554c8d3e33643945442

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

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
