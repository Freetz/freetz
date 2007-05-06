JPEG_VERSION:=6b
JPEG_SOURCE:=jpegsrc.v$(JPEG_VERSION).tar.gz
JPEG_SITE:=http://ijg.org/files
JPEG_DIR:=$(SOURCE_DIR)/jpeg-$(JPEG_VERSION)
JPEG_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(JPEG_SOURCE):
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
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib -static-libgcc" \
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

$(JPEG_DIR)/.compiled: $(JPEG_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(JPEG_DIR) \
		$(TARGET_CONFIGURE_OPTS) all
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.so: $(JPEG_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(JPEG_DIR) \
		libdir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		includedir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		install-headers install-lib
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
jpeg jpeg-precompiled:
	@echo 'External compiler used. Skipping libjpeg...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libjpeg*.so* root/usr/lib/
else
jpeg: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg.so
jpeg-precompiled: uclibc jpeg
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*.so* root/usr/lib/
endif

jpeg-source: $(JPEG_DIR)/.unpacked

jpeg-clean:
	-$(MAKE) -C $(JPEG_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libjpeg*
	rm -rf root/usr/lib/libjpeg*.so*

jpeg-dirclean:
	rm -rf $(JPEG_DIR)
