$(call PKG_INIT_BIN, 0.0.1)
$(PKG)_SOURCE:=simple-obfs-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=69fd78e373f2893b8742c5263464785d
$(PKG)_SITE:=@SF/simpleobfs
$(PKG)_BINARY:=$($(PKG)_DIR)/src/obfs-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/obfs-server
$(PKG)_CATEGORY:=Unstable

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG)_CONFIGURE_PRE_CMDS += AUTOGEN_SUBDIR_MODE=y ./autogen.sh ;
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
$(PKG)_CONFIGURE_OPTIONS += --enable-shared --disable-documentation --disable-debug
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SIMPLEOBFS_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SIMPLEOBFS_DIR) clean
	$(RM) $(EMPTY_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SIMPLEOBFS_TARGET_BINARY)

$(PKG_FINISH)
