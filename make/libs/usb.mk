USB_VERSION:=0.1.12
USB_SHORT_VERSION:=0.1
USB_LIB_VERSION:=4.4.4
USB_SOURCE:=libusb-$(USB_VERSION).tar.gz
USB_SITE:=http://prdownloads.sourceforge.net/libusb
USB_MAKE_DIR:=$(MAKE_DIR)/libs
USB_DIR:=$(SOURCE_DIR)/libusb-$(USB_VERSION)
USB_BINARY:=$(USB_DIR)/.libs/libusb-$(USB_SHORT_VERSION).so.$(USB_LIB_VERSION)
USB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb-$(USB_SHORT_VERSION).so.$(USB_LIB_VERSION)
USB_TARGET_DIR:=root/usr/lib
USB_TARGET_BINARY:=$(USB_TARGET_DIR)/libusb-$(USB_SHORT_VERSION).so.$(USB_LIB_VERSION)


$(DL_DIR)/$(USB_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(USB_SITE)/$(USB_SOURCE)

$(USB_DIR)/.unpacked: $(DL_DIR)/$(USB_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(USB_SOURCE)
	for i in $(USB_MAKE_DIR)/patches/*.usb.patch; do \
		$(PATCH_TOOL) $(USB_DIR) $$i; \
	done
	touch $@

$(USB_DIR)/.configured: $(USB_DIR)/.unpacked
	( cd $(USB_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		ac_cv_header_regex_h=no \
		ac_cv_c_bigendian=no \
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

$(USB_BINARY): $(USB_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
	$(MAKE) -C $(USB_DIR) all

$(USB_STAGING_BINARY): $(USB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(USB_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb.la
	$(SED) -i -e "s,^inlcudedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libusb.mk

$(USB_TARGET_BINARY): $(USB_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libusb*.so* $(USB_TARGET_DIR)/
	$(TARGET_STRIP) $@

usb: $(USB_STAGING_BINARY)

usb-precompiled: uclibc usb $(USB_TARGET_BINARY)

usb-source: $(USB_DIR)/.unpacked

usb-clean:
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/libusb-config
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/includes/usb*.h
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libusb*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig
	-$(MAKE) -C $(LIBUSB_DIR) clean

usb-uninstall:
	rm -f $(USB_TARGET_DIR)/libusb*.so*

usb-dirclean:
	rm -rf $(USB_DIR)
