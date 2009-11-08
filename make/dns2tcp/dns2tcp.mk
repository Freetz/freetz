$(call PKG_INIT_BIN,0.4.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.hsc.fr/ressources/outils/dns2tcp/download
$(PKG)_BINARY:=$($(PKG)_DIR)/server/dns2tcpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/dns2tcpd
$(PKG)_SOURCE_MD5:=d2b322ee27f4ff53dfdad61aa2f42dd8 

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(DNS2TCP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(DNS2TCP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DNS2TCP_TARGET_BINARY)

$(PKG_FINISH)
