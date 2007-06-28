PJSIP_VERSION:=0.7.0
PJSIP_LIB_VERSION:=0.7.0
PJSIP_SOURCE:=pjproject-0.7.0.tar.gz
PJSIP_SITE:=http://fritz.v3v.de/dtmfbox/dtmfbox-src/libs
PJSIP_MAKE_DIR:=$(MAKE_DIR)/libs
PJSIP_DIR:=$(SOURCE_DIR)/pjproject-0.7.0
PJSIP_BINARY:=$(PJSIP_DIR)/libpjsip.so.$(PJSIP_LIB_VERSION)
PJSIP_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip.so.$(PJSIP_LIB_VERSION)
PJSIP_TARGET_DIR:=root/usr/lib
PJSIP_TARGET_BINARY:=$(PJSIP_TARGET_DIR)/libpjsip.so.$(PJSIP_LIB_VERSION)

$(DL_DIR)/$(PJSIP_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(PJSIP_SITE)/$(PJSIP_SOURCE)
    
$(PJSIP_DIR)/.unpacked: $(DL_DIR)/$(PJSIP_SOURCE)
	tar -C $(SOURCE_DIR) -xvzf $(DL_DIR)/$(PJSIP_SOURCE)	
	touch $@

$(PJSIP_DIR)/.configured: $(PJSIP_DIR)/.unpacked
	( cd $(PJSIP_DIR); rm -f config.{cache,status}; \
		cat build.mak.in | sed 's/@LIBS@/-Wl,-Bdynamic @LIBS@/g' > build.mak.in.tmp; \
		mv build.mak.in.tmp build.mak.in; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-lm" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
		--enable-shared \
		--disable-sound \
		--disable-large-filter \
		--disable-small-filter \
		--disable-speex-aec \
		--disable-l16-codec \
		--disable-gsm-codec \
		--disable-speex-codec \
		--disable-ilbc-codec \
		--disable-ssl \
		--disable-floating-point \
	);
	touch $@


$(PJSIP_BINARY): $(PJSIP_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH); \
	    $(MAKE) -C $(PJSIP_DIR) dep; \
	    $(MAKE1) -C $(PJSIP_DIR) all

$(PJSIP_STAGING_BINARY): $(PJSIP_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	    $(MAKE) -C $(PJSIP_DIR) \
	    DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
	    install

$(PJSIP_TARGET_BINARY): $(PJSIP_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip*.so* $(PJSIP_TARGET_DIR)
	$(TARGET_STRIP) $@

pjsip: $(PJSIP_STAGING_BINARY)

pjsip-precompiled: uclibc pjsip $(PJSIP_TARGET_BINARY)

pjsip-source: $(PJSIP_DIR)/.unpacked

pjsip-clean:
	-$(MAKE) -C $(PJSIP_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpjsip.* 

pjsip-uninstall:
	rm -f $(PJSIP_TARGET_DIR)/libpjsip*.so*
    
pjsip-dirclean:
	rm -rf $(PJSIP_DIR)
