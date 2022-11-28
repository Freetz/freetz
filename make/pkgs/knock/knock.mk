$(call PKG_INIT_BIN, 0.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=698d8c965624ea2ecb1e3df4524ed05afe387f6d20ded1e8a231209ad48169c7
$(PKG)_SITE:=https://github.com/jvinet/knock/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://www.zeroflux.org/projects.html
### MANPAGE:=https://linux.die.net/man/1/knockd
### CHANGES:=https://github.com/jvinet/knock/blob/master/ChangeLog
### CVSREPO:=https://github.com/jvinet/knock

$(PKG)_KNOCK_BINARY:=$($(PKG)_DIR)/knock
$(PKG)_KNOCKD_BINARY:=$($(PKG)_DIR)/knockd
$(PKG)_TARGET_KNOCK_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/knock
$(PKG)_TARGET_KNOCKD_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/knockd

$(PKG)_DEPENDS_ON += libpcap


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_KNOCK_BINARY) $($(PKG)_KNOCKD_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(KNOCK_DIR)

$($(PKG)_TARGET_KNOCK_BINARY): $($(PKG)_KNOCK_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_KNOCKD_BINARY): $($(PKG)_KNOCKD_BINARY)
	$(INSTALL_BINARY_STRIP)


$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_KNOCK_BINARY) $($(PKG)_TARGET_KNOCKD_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(KNOCK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(KNOCK_TARGET_KNOCK_BINARY)
	$(RM) $(KNOCK_TARGET_KNOCKD_BINARY)

$(PKG_FINISH)
