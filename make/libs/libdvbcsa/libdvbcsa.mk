$(call PKG_INIT_LIB, 1.1.0)
$(PKG)_LIB_VERSION:=1.0.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=4db78af5cdb2641dfb1136fe3531960a477c9e3e3b6ba19a2754d046af3f456d
$(PKG)_SITE:=https://download.videolan.org/pub/videolan/libdvbcsa/$($(PKG)_VERSION)
### WEBSITE:=https://www.videolan.org/developers/libdvbcsa.html
### MANPAGE:=https://code.videolan.org/videolan/libdvbcsa/blob/master/README
### CHANGES:=https://code.videolan.org/videolan/libdvbcsa/blob/master/ChangeLog
### CVSREPO:=https://code.videolan.org/videolan/libdvbcsa/

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libdvbcsa.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdvbcsa.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libdvbcsa.so.$($(PKG)_LIB_VERSION)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBDVBCSA_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBDVBCSA_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdvbcsa.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBDVBCSA_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libdvbcsa* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libdvbcsa \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/doc/libdvbcsa

$(pkg)-uninstall:
	$(RM) $(LIBDVBCSA_TARGET_DIR)/libdvbcsa.so*

$(PKG_FINISH)
