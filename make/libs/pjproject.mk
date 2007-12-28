$(call PKG_INIT_LIB, 0.8.0)
$(PKG)_LIB_VERSION:=0.8.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://fritz.v3v.de/dtmfbox/libs
$(PKG)_BINARY:=$($(PKG)_DIR)/pjsip/lib/libpjsip.a
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip.a
# only static lib
#$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpjsip.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-sound
$(PKG)_CONFIGURE_OPTIONS += --disable-large-filter
$(PKG)_CONFIGURE_OPTIONS += --disable-small-filter
$(PKG)_CONFIGURE_OPTIONS += --disable-speex-aec
$(PKG)_CONFIGURE_OPTIONS += --disable-l16-codec
$(PKG)_CONFIGURE_OPTIONS += --disable-gsm-codec
$(PKG)_CONFIGURE_OPTIONS += --disable-speex-codec
$(PKG)_CONFIGURE_OPTIONS += --disable-ilbc-codec
$(PKG)_CONFIGURE_OPTIONS += --disable-ssl
$(PKG)_CONFIGURE_OPTIONS += --disable-floating-point
$(PKG)_CONFIGURE_OPTIONS += --disable-libsamplerate

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.depend: $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) LDFLAGS="-lm" CFLAGS="$(TARGET_CFLAGS) -DPJ_DEBUG=0 -DNDEBUG=0" \
		$(MAKE) -C $(PJPROJECT_DIR) dep \
		TARGET_NAME="$(REAL_GNU_TARGET_NAME)"
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.depend
	PATH=$(TARGET_TOOLCHAIN_PATH) LDFLAGS="-lm" CFLAGS="$(TARGET_CFLAGS) -DPJ_DEBUG=0 -DNDEBUG=0" \
		$(MAKE) -C $(PJPROJECT_DIR) all \
		TARGET_NAME="$(REAL_GNU_TARGET_NAME)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(PJPROJECT_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
		install

#$(PJSIP_TARGET_BINARY): $(PJSIP_STAGING_BINARY)
#	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip*.so* $(PJPROJECT_TARGET_DIR)
#	$(TARGET_STRIP) $@

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled:

$(pkg)-clean:
	-$(MAKE) -C $(PJPROJECT_DIR) \
		TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
		clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpj*.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libresample.a
	 

#$(pkg)-uninstall:
#	rm -f $(PJPROJECT_TARGET_DIR)/libpjsip*.so*

$(PKG_FINISH)
