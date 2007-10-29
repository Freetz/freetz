PACKAGE_LC:=pjsip
PACKAGE_UC:=PJSIP
$(PACKAGE_UC)_VERSION:=0.7.0
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=0.7.0
$(PACKAGE_UC)_SOURCE:=pjproject-0.7.0.tar.gz
$(PACKAGE_UC)_SITE:=http://fritz.v3v.de/dtmfbox/libs
$(PACKAGE_UC)_DIR:=$(SOURCE_DIR)/pjproject-0.7.0
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/pjsip/lib/libpjsip.a
$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip.a
# only static lib
#$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libpjsip.so.$($(PACKAGE_UC)_LIB_VERSION)
		
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += cat build.mak.in | sed 's/@LIBS@/-Wl,-Bdynamic @LIBS@/g' > build.mak.in.tmp;
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += mv build.mak.in.tmp build.mak.in;
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-sound
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-large-filter
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-small-filter
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-speex-aec
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-l16-codec
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-gsm-codec
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-speex-codec
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ilbc-codec
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-ssl
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-floating-point
$(PACKAGE_UC)_CONFIGURE_OPTIONS += CFLAGS="$(TARGET_CFLAGS) -DPJ_DEBUG=0 -DNDEBUG=0"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += LDFLAGS="-lm"
		
$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_DIR)/.depend: $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) dep \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)"
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.depend
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) all \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)"

$($(PACKAGE_UC)_STAGING_BINARY): $($(PACKAGE_UC)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
	    install

#$(PJSIP_TARGET_BINARY): $(PJSIP_STAGING_BINARY)
#	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip*.so* $(PJSIP_TARGET_DIR)
#	$(TARGET_STRIP) $@

pjsip: $($(PACKAGE_UC)_STAGING_BINARY)

pjsip-precompiled: uclibc pjsip #$($(PACKAGE_UC)_TARGET_BINARY)

pjsip-clean:
	-$(MAKE) -C $(PJSIP_DIR) \
	    TARGET_NAME="$(REAL_GNU_TARGET_NAME)" \
	    clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpj*.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libresample.a
	 

#pjsip-uninstall:
#	rm -f $(PJSIP_TARGET_DIR)/libpjsip*.so*
    
$(PACKAGE_FINI)