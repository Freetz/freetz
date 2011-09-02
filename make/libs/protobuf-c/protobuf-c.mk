$(call PKG_INIT_LIB, 0.15)
$(PKG)_LIB_VERSION:=0.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=73ff0c8df50d2eee75269ad8f8c07dc8
$(PKG)_SITE:=http://$(pkg).googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/libprotobuf-c.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libprotobuf-c.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libprotobuf-c.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-protoc
$(PKG)_CONFIGURE_OPTIONS += --with-endianness=$(if $(FREETZ_TARGET_ARCH_BE),big,little)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PROTOBUF_C_DIR)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(PROTOBUF_C_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libprotobuf-c.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libprotobuf-c.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PROTOBUF_C_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/google/protobuf-c \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libprotobuf-c* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libprotobuf-c.pc

$(pkg)-uninstall:
	$(RM) $(PROTOBUF_C_TARGET_DIR)/libprotobuf-c.so*

$(PKG_FINISH)
