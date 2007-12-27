$(call PKG_INIT_LIB, 0.8.0)
$(PKG)_LIB_VERSION:=0.8.0
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://fritz.v3v.de/dtmfbox/libs
$(PKG)_BINARY:=$($(PKG)_DIR)/pjsip/lib/libpjsip.a
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip.a
# only static lib
#$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpjsip.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_DEFOPTS := n

$(PKG)_CONFIGURE_ENV += CFLAGS="$(TARGET_CFLAGS) -DPJ_DEBUG=0 -DNDEBUG=0"
#-DPJMEDIA_HAS_SPEEX_AEC=0 -DPJMEDIA_HAS_L16_CODEC=0 -DPJMEDIA_HAS_GSM_CODEC=0 -DPJMEDIA_HAS_SPEEX_CODEC=0 -DPJMEDIA_HAS_ILBC_CODEC=0 -DPJMEDIA_SOUND_IMPLEMENTATION=PJMEDIA_SOUND_NULL_SOUND -DPJMEDIA_RESAMPLE_IMP=PJMEDIA_RESAMPLE_LIBRESAMPLE"
$(PKG)_CONFIGURE_ENV += LDFLAGS="-lm"

$(PKG)_CONFIGURE_OPTIONS += --target=$(GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --host=$(GNU_TARGET_NAME)
$(PKG)_CONFIGURE_OPTIONS += --build=$(GNU_HOST_NAME)
$(PKG)_CONFIGURE_OPTIONS += --program-prefix=""
$(PKG)_CONFIGURE_OPTIONS += --program-suffix=""
$(PKG)_CONFIGURE_OPTIONS += --prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --exec-prefix=/usr
$(PKG)_CONFIGURE_OPTIONS += --bindir=/usr/bin
$(PKG)_CONFIGURE_OPTIONS += --datadir=/usr/share
$(PKG)_CONFIGURE_OPTIONS += --includedir=/usr/include
$(PKG)_CONFIGURE_OPTIONS += --infodir=/usr/share/info
$(PKG)_CONFIGURE_OPTIONS += --libdir=/usr/lib
$(PKG)_CONFIGURE_OPTIONS += --libexecdir=/usr/lib
$(PKG)_CONFIGURE_OPTIONS += --localstatedir=/var
$(PKG)_CONFIGURE_OPTIONS += --mandir=/usr/share/man
$(PKG)_CONFIGURE_OPTIONS += --sbindir=/usr/sbin
$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/etc
$(PKG)_CONFIGURE_OPTIONS += $(DISABLE_NLS)
$(PKG)_CONFIGURE_OPTIONS += $(DISABLE_LARGEFILE)
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
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(PJPROJECT_DIR) dep \
		TARGET_NAME="$(REAL_GNU_TARGET_NAME)"
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.depend
	PATH=$(TARGET_TOOLCHAIN_PATH) \
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