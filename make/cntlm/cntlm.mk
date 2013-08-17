$(call PKG_INIT_BIN, 0.93beta5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c144e8b34faeabe573045deaeeba2791
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
