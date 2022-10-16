$(call PKG_INIT_BIN, 2.7.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ca48d2f17e071deead5e6e9cc9e388bf6a3270d695e61976b3794d4d927b5c4e
$(PKG)_SITE:=https://www.atoptool.nl/download
### WEBSITE:=https://www.atoptool.nl/
### MANPAGE:=https://linux.die.net/man/1/atop
### CHANGES:=https://www.atoptool.nl/downloadatop.php

$(PKG)_BINARY:=$($(PKG)_DIR)/atop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/atop

$(PKG)_DEPENDS_ON += zlib ncursesw


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ATOP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -Wall" \
		atop

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(ATOP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(ATOP_TARGET_BINARY)

$(PKG_FINISH)
