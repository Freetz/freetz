$(eval $(call PKG_INIT_LIB, 0.7.0))
$(PKG)_LIB_VERSION:=0.7.0
$(PKG)_SOURCE:=pjproject-0.7.0.tar.gz
$(PKG)_SITE:=http://fritz.v3v.de/dtmfbox/libs
$(PKG)_DIR:=$(SOURCE_DIR)/pjproject-0.7.0
$(PKG)_BINARY:=$($(PKG)_DIR)/pjsip/lib/libpjsip.a
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip.a
# only static lib
#$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpjsip.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_PRE_CMDS += sed -i 's/@LIBS@/-Wl,-Bdynamic @LIBS@/g' build.mak.in;
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
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
$(PKG)_CONFIGURE_OPTIONS += CFLAGS="$(TARGET_CFLAGS) -DPJ_DEBUG=0 -DNDEBUG=0"
$(PKG)_CONFIGURE_OPTIONS += LDFLAGS="-lm"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.depend: $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) dep \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)"
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.depend
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) all \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)"

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
	    install

#$(PJSIP_TARGET_BINARY): $(PJSIP_STAGING_BINARY)
#	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip*.so* $(PJSIP_TARGET_DIR)
#	$(TARGET_STRIP) $@

pjsip: $($(PKG)_STAGING_BINARY)

pjsip-precompiled: uclibc pjsip #$($(PKG)_TARGET_BINARY)

pjsip-clean:
	-$(MAKE) -C $(PJSIP_DIR) \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
	    clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpj*.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libresample.a
	 

#pjsip-uninstall:
#	rm -f $(PJSIP_TARGET_DIR)/libpjsip*.so*
    
$(PKG_FINISH)