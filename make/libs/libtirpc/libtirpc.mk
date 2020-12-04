$(call PKG_INIT_LIB, 1.2.6)
$(PKG)_LIB_VERSION:=3.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_SHA256:=4278e9a5181d5af9cd7885322fdecebc444f9a3da87c526e7d47f7a12a37d1cc
$(PKG)_SITE:=@SF/libtirpc

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtirpc.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libtirpc.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --without-openldap
$(PKG)_CONFIGURE_OPTIONS += --disable-gssapi

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBTIRPC_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBTIRPC_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libtirpc.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBTIRPC_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libtirpc.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/tirpc/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libtirpc.pc

$(pkg)-uninstall:
	$(RM) $(LIBTIRPC_TARGET_DIR)/libtirpc.so*

$(PKG_FINISH)
