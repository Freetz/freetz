$(call PKG_INIT_BIN, 3.5.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ff44cc792e43e57fd3392faee3e52c82002a2aaa4a79e255667cfcd6cd64580f
$(PKG)_SITE:=@SF/ser2net
### WEBSITE:=https://ser2net.sourceforge.net/
### MANPAGE:=https://linux.die.net/man/8/ser2net
### CHANGES:=https://sourceforge.net/p/ser2net/news/
### CVSREPO:=https://sourceforge.net/projects/ser2net/

$(PKG)_BINARY:=$($(PKG)_DIR)/ser2net
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ser2net

$(PKG)_CONFIGURE_OPTIONS += --with-pthreads=no
$(PKG)_CONFIGURE_OPTIONS += --with-openipmi=no


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SER2NET_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SER2NET_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SER2NET_TARGET_BINARY)

$(PKG_FINISH)
