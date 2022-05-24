$(call PKG_INIT_LIB, 1.1.0)
$(PKG)_LIB_VERSION:=1.0.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9a973fc04aac003f9cf2b5a90ac4b8fa294cacb4e3f0796d3b5a789a5ad46c07
$(PKG)_SITE:=https://github.com/$(pkg)/$(pkg)/releases/download/v$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/protobuf-c/.libs/libprotobuf-c.so.$($(PKG)_LIB_VERSION)
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
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/protobuf-c \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/google/protobuf-c \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libprotobuf-c* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libprotobuf-c.pc

$(pkg)-uninstall:
	$(RM) $(PROTOBUF_C_TARGET_DIR)/libprotobuf-c.so*

$(PKG_FINISH)
