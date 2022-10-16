$(call PKG_INIT_BIN, 1.1.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=a259750793ab79c491d05fcee5a917faf7d9030fb5d15e05b3704e9c9e4ee015
$(PKG)_SITE:=http://www.pps.univ-paris-diderot.fr/~jch/software/files/$(pkg)
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
