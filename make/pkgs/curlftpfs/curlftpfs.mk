$(call PKG_INIT_BIN, 0.9.2)
$(PKG)_LIB_VERSION:=4.1.1
$(PKG)_SOURCE:=curlftpfs-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4eb44739c7078ba0edde177bdd266c4cfb7c621075f47f64c85a06b12b3c6958
$(PKG)_SITE:=@SF/curlftpfs
$(PKG)_BINARY:=$($(PKG)_DIR)/curlftpfs
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/curlftpfs

$(PKG)_EXCLUDED+=$(if $(FREETZ_PACKAGE_CURLFTPFS_REMOVE_WEBIF),usr/lib/cgi-bin/curlftpfs.cgi etc/default.curlftpfs etc/init.d/rc.curlftpfs)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_CURLFTPFS_STATIC

$(PKG)_DEPENDS_ON += fuse glib2 curl
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_CONFIGURE_ENV += am_cv_func_iconv=yes
$(PKG)_CONFIGURE_OPTIONS += --with-libiconv-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)"
else
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURLFTPFS_STATIC),--disable-shared,--enable-shared)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_CURLFTPFS_STATIC),--enable-static,--disable-static)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_EXTRA_LIBS:=-lfuse $(if $(FREETZ_TARGET_UCLIBC_0_9_28),-liconv) -lcurl -lglib-2.0 -lpthread
ifeq ($(strip $(FREETZ_PACKAGE_CURLFTPFS_STATIC)),y)
$(PKG)_EXTRA_LIBS += -lssl -lcrypto -ldl
$(PKG)_EXTRA_LDFLAGS += -all-static
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CURLFTPFS_DIR) \
		EXTRA_LDFLAGS="$(CURLFTP_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(CURLFTP_EXTRA_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CURLFTPFS_DIR) clean
	$(RM) $(CURLFTPFS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(CURLFTPFS_TARGET_BINARY)

$(PKG_FINISH)
