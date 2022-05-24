$(call PKG_INIT_BIN, 1.0.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=2e1a4c0cc3a2f489b73b2f15f009067eb41af5a865e3d5701ba00f5cfb70ab57
$(PKG)_SITE:=http://www.clevervest.com/htp/archive/c/
$(PKG)_BINARIES:=$(pkg)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_HTPDATE_REMOVE_WEBIF),etc/default.htpdate etc/onlinechanged/10-htpdate etc/init.d/rc.htpdate usr/lib/cgi-bin/htpdate.cgi)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(HTPDATE_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(HTPDATE_DIR) clean
	$(RM) $(HTPDATE_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTPDATE_BINARIES_TARGET_DIR)

$(PKG_FINISH)
