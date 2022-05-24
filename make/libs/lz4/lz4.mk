$(call PKG_INIT_LIB, v1.9.3)
$(PKG)_LIB_VERSION:=1.9.3
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=X
$(PKG)_SITE:=git@https://github.com/lz4/lz4.git

$(PKG)_BINARY:=$($(PKG)_DIR)/lib/liblz4.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblz4.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/liblz4.so.$($(PKG)_LIB_VERSION)

$(PKG)_MAKE_VARS += CC="$(TARGET_CC)"
$(PKG)_MAKE_VARS += CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_MAKE_VARS += AR="$(TARGET_AR)"
$(PKG)_MAKE_VARS += PREFIX=/usr
$(PKG)_MAKE_VARS += V=1

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LZ4_DIR)/lib \
		$(LZ4_MAKE_VARS)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LZ4_DIR)/lib \
		$(LZ4_MAKE_VARS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/liblz4.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LZ4_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblz4* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/lz4*.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/liblz4.pc

$(pkg)-uninstall:
	$(RM) $(LZ4_TARGET_DIR)/liblz4*.so*

$(PKG_FINISH)
