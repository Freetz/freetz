$(call PKG_INIT_LIB, 1.2.1)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA1:=f65fbbd72926c8e7cf0dbd4ada03b0d226f461fd
$(PKG)_SITE:=https://serf.googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/.libs/libserf-1.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libserf-1.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libserf-1.so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += apr apr-util openssl zlib

$(PKG)_CONFIGURE_OPTIONS += --with-apr="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-apr-util="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SERF_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(SERF_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libserf-1.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/serf-1.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SERF_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libserf-1.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/serf-1.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/{serf.h,serf_*.h}

$(pkg)-uninstall:
	$(RM) $(SERF_TARGET_DIR)/libserf-1.so*

$(PKG_FINISH)
