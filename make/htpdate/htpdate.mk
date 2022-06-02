$(call PKG_INIT_BIN, 1.3.4)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=744f9200cfd3b008a5516c5eb6da727af532255a329126a7b8f49a5623985642
$(PKG)_SITE:=https://www.vervest.org/htp/archive/c
### WEBSITE:=http://www.vervest.org/htp/
### MANPAGE:=https://www.vervest.org/htp/?FAQ
### CHANGES:=https://github.com/twekkel/htpdate/blob/master/Changelog
### CVSREPO:=https://github.com/twekkel/htpdate

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
