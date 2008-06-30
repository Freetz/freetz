$(call PKG_INIT_BIN, 0.7.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/wake-on-lan
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_DEPENDS_ON := 
$(PKG)_CONFIGURE_ENV := jm_cv_func_working_malloc=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured $(CURL_LIB_STAGING_BINARY)
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(WOL_DIR) \
		CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(WOL_DIR) clean

$(pkg)-uninstall:
	rm -f $(WOL_TARGET_BINARY)

$(PKG_FINISH)
