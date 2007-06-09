JPEG_VERSION:=6b
JPEG_LIB_VERSION:=62.0.0
JPEG_SOURCE:=jpegsrc.v$(JPEG_VERSION).tar.gz
JPEG_SITE:=http://ijg.org/files
JPEG_MAKE_DIR:=$(MAKE_DIR)/libs
JPEG_DIR:=$(SOURCE_DIR)/jpeg-$(JPEG_VERSION)
JPEG_BINARY:=$(JPEG_DIR)/.libs/libjpeg.so.$(JPEG_LIB_VERSION)
JPEG_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.so.$(JPEG_LIB_VERSION)
JPEG_TARGET_DIR:=root/usr/lib
JPEG_TARGET_BINARY:=$(JPEG_TARGET_DIR)/libjpeg.so.$(JPEG_LIB_VERSION)


$(DL_DIR)/$(JPEG_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(JPEG_SITE)/$(JPEG_SOURCE)

$(JPEG_DIR)/.unpacked: $(DL_DIR)/$(JPEG_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(JPEG_SOURCE)
	for i in $(JPEG_MAKE_DIR)/patches/*.jpeg.patch; do \
		patch -d $(JPEG_DIR) -p1 < $$i; \
	done
	touch $@

$(JPEG_DIR)/.configured: $(JPEG_DIR)/.unpacked
	( cd $(JPEG_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CC)" \
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
		--enable-static \
	);
	touch $@

$(JPEG_BINARY): $(JPEG_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(JPEG_DIR) \
		$(TARGET_CONFIGURE_OPTS) all

$(JPEG_STAGING_BINARY): $(JPEG_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(JPEG_DIR) \
		libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		includedir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		install-headers install-lib

$(JPEG_TARGET_BINARY): $(JPEG_STAGING_BINARY)
	$(TARGET_STRIP) $(JPEG_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*.so* $(JPEG_TARGET_DIR)/

jpeg: $(JPEG_STAGING_BINARY)

jpeg-precompiled: uclibc jpeg $(JPEG_TARGET_BINARY)

jpeg-source: $(JPEG_DIR)/.unpacked

jpeg-clean:
	-$(MAKE) -C $(JPEG_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*

jpeg-uninstall:
	rm -f $(JPEG_TARGET_DIR)/libjpeg*.so*

jpeg-dirclean:
	rm -rf $(JPEG_DIR)
