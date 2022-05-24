$(call PKG_INIT_BIN, 0.93beta5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=97d0d7162e1c782a74958af3b7f48f61ae72b49d2f608d21155f804583a6a754
$(PKG)_SITE:=http://ftp.awk.cz/pub

$(PKG)_BINARY:=$($(PKG)_DIR)/cntlm
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/cntlm

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CNTLM_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		SYSCONFDIR=/mod/etc

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CNTLM_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CNTLM_TARGET_BINARY)

$(PKG_FINISH)
