$(call PKG_INIT_BIN, 1.0.4.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://freehaven.net/~chrisd/$(pkg)
$(PKG)_SOURCE_MD5:=bfc5c85289519658280e093a270d6703
$(PKG)_BINARY:=$($(PKG)_DIR)/polipo
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/polipo

ifeq ($(strip $(FREETZ_PACKAGE_POLIPO_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_POLIPO_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.unpacked
	$(SUBMAKE) -C $(POLIPO_DIR) \
		CC="$(TARGET_CC)" \
		LDFLAGS="$(POLIPO_LDFLAGS)" \
		CDEBUGFLAGS="$(TARGET_CFLAGS)" 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(POLIPO_DIR) clean

$(pkg)-uninstall:
	$(RM) $(POLIPO_TARGET_BINARY)

$(PKG_FINISH)
