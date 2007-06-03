USB_VERSION:=0.1.12
USB_SOURCE:=libusb-$(USB_VERSION).tar.gz
USB_SITE:=http://prdownloads.sourceforge.net/libusb
USB_DIR:=$(SOURCE_DIR)/libusb-$(USB_VERSION)
USB_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(USB_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(USB_SITE)/$(USB_SOURCE)

$(USB_DIR)/.unpacked: $(DL_DIR)/$(USB_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(USB_SOURCE)
	for i in $(USB_MAKE_DIR)/patches/*.usb.patch; do \
		patch -d $(USB_DIR) -p0 < $$i; \
	done
	touch $@

$(USB_DIR)/.configured: $(USB_DIR)/.unpacked
	( cd $(USB_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib -static-libgcc" \
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

$(USB_DIR)/.compiled: $(USB_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(USB_DIR) \
		$(TARGET_CONFIGURE_OPTS) all
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb.so: $(USB_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(USB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

usb: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb.so

usb-precompiled: uclibc usb
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb*.so* root/usr/lib/

usb-source: $(USB_DIR)/.unpacked

usb-clean:
	-$(MAKE) -C $(USB_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb*
	rm -rf root/usr/lib/libusb*.so*

usb-dirclean:
	rm -rf $(USB_DIR)
