$(call PKG_INIT_BIN,0.23)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=44a74ff288d38c0f75354d6bc2efe7d6dec10112eaff2e7b10e292b0d2105b36
$(PKG)_SITE:=http://triq.net/obexftp
$(PKG)_BINARY:=$($(PKG)_DIR)/apps/obexftpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/obexftpd

$(PKG)_DEPENDS_ON += bluez-libs openobex

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --disable-swig
$(PKG)_CONFIGURE_OPTIONS += --disable-perl
$(PKG)_CONFIGURE_OPTIONS += --disable-python
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-ruby
$(PKG)_CONFIGURE_OPTIONS += --disable-tcl
$(PKG)_CONFIGURE_OPTIONS += --disable-builddocs
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OBEXFTP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OBEXFTP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OBEXFTP_TARGET_BINARY)

$(PKG_FINISH)
