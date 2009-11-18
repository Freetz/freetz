$(call PKG_INIT_BIN, 20070115)
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://noc.sixxs.net/archive/sixxs/aiccu/unix
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)
$(PKG)_BINARY:=$($(PKG)_DIR)/unix-console/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)
$(PKG)_SOURCE_MD5:=c9bcc83644ed788e22a7c3f3d4021350

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(AICCU_DIR) aiccu \
		CC="$(TARGET_CC)" \
		RPM_OPT_FLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(AICCU_DIR) clean

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
