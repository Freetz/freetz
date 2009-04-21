$(call PKG_INIT_LIB, 0.9.8)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.tcpdump.org/release/
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --with-pcap=linux
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-pthread
$(PKG)_CONFIGURE_OPTIONS += --enable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-plugins
$(PKG)_CONFIGURE_OPTIONS += --disable-management
$(PKG)_CONFIGURE_OPTIONS += --disable-socks
$(PKG)_CONFIGURE_OPTIONS += --disable-http
$(PKG)_CONFIGURE_OPTIONS += --enable-password-save
$(PKG)_CONFIGURE_OPTIONS += --enable-small
$(PKG)_CONFIGURE_OPTIONS += --disable-yydebug
$(PKG)_CONFIGURE_OPTIONS += --with-build-cc="$(HOSTCC)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)


$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPCAP_DIR) all \
		CCOPT="-fPIC $(TARGET_CFLAGS)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LIBPCAP_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap*.so* $(LIBPCAP_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(LIBPCAP_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpcap* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pcap* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/man/man3/pcap.3

$(pkg)-uninstall:
	$(RM) $(LIBPCAP_TARGET_DIR)/libpcap*.so*

$(PKG_FINISH)
