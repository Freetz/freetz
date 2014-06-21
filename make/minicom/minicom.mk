$(call PKG_INIT_BIN,2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=a5117d4d21e2c9e825edb586ee2fe8d2
$(PKG)_SITE:=http://alioth.debian.org/frs/download.php/3487

$(PKG)_BINARY:=$($(PKG)_DIR)/src/minicom
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/minicom

$(PKG)_DEPENDS_ON += ncurses
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINICOM_PORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MINICOM_BAUD

$(PKG)_CONFIGURE_OPTIONS += --enable-cfg-dir=/var/tmp/flash/minicom/
$(PKG)_CONFIGURE_OPTIONS += --enable-dfl-port=$(FREETZ_PACKAGE_MINICOM_PORT)
$(PKG)_CONFIGURE_OPTIONS += --enable-dfl-baud=$(FREETZ_PACKAGE_MINICOM_BAUD)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MINICOM_DIR) \
		ICONVLIB="$(if $(FREETZ_TARGET_UCLIBC_0_9_28),-liconv)" \
		AM_CFLAGS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MINICOM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MINICOM_TARGET_BINARY)

$(PKG_FINISH)
