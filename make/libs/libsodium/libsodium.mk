$(call PKG_INIT_LIB, 1.0.11)
$(PKG)_LIB_VERSION:=18.1.1
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=b58928d035064b2a46fb564937b83540
$(PKG)_SITE:=https://download.libsodium.org/libsodium/releases/

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --enable-minimal
$(PKG)_CONFIGURE_OPTIONS += --disable-soname-versions
$(PKG)_CONFIGURE_OPTIONS += --disable-blocking-random
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBSODIUM_DIR) all \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		CCOPT="$(TARGET_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBSODIUM_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsodium.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBSODIUM_DIR) clean
#	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap* \
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcap*

$(pkg)-uninstall:
	$(RM) $(LIBSODIUM_TARGET_DIR)/libsodium*.so*

$(PKG_FINISH)
