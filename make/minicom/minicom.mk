$(call PKG_INIT_BIN,1fb24b4f)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=X
$(PKG)_SITE:=git@https://salsa.debian.org/minicom-team/minicom.git
### WEBSITE:=https://salsa.debian.org/minicom-team/minicom
### MANPAGE:=https://linux.die.net/man/1/minicom
### CHANGES:=https://salsa.debian.org/minicom-team/minicom/-/releases
### CVSREPO:=https://salsa.debian.org/minicom-team/minicom/-/commits/master/

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

