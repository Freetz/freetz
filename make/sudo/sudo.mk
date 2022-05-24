$(call PKG_INIT_BIN, 1.7.10p8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=8e1df217dc7f32eb770c3b6fba88953263bdca28ce45439eb8527c6c3c959abd
$(PKG)_SITE:=http://www.sudo.ws/sudo/dist

$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_DIR)/$(pkg)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_LIBS:=lib$(pkg)_noexec.so
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DIR)/.libs/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_OPTIONS += --without-lecture \
			    --without-pam \
			    --without-sendmail \
			    --disable-pam-session \
			    --disable-root-mailer \
			    --disable-root-sudo \
			    --sysconfdir=/mod/etc \
			    --disable-zlib

$(PKG)_CONFIGURE_ENV += sudo_cv_uid_t_len=10

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(SUDO_DIR)

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)
	chmod +s $(SUDO_BINARY_TARGET_DIR)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(SUDO_DIR) clean
	$(RM) $(SUDO_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(SUDO_BINARY_TARGET_DIR) $(SUDO_LIBS_TARGET_DIR)

$(PKG_FINISH)
