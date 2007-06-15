FFI_SABLE_VERSION:=3325
FFI_SABLE_LIB_VERSION:=4.0.1
FFI_SABLE_SOURCE:=libffi-sable-$(FFI_SABLE_VERSION).tar.gz
FFI_SABLE_SITE:=http://ftp.iasi.roedu.net/mirrors/openwrt.org/sources
FFI_SABLE_MAKE_DIR:=$(MAKE_DIR)/libs
FFI_SABLE_DIR:=$(SOURCE_DIR)/libffi-sable-$(FFI_SABLE_VERSION)
FFI_SABLE_BINARY:=$(FFI_SABLE_DIR)/.libs/libffi.so.$(FFI_SABLE_LIB_VERSION)
FFI_SABLE_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so.$(FFI_SABLE_LIB_VERSION)
FFI_SABLE_TARGET_DIR:=root/usr/lib
FFI_SABLE_TARGET_BINARY:=$(FFI_SABLE_TARGET_DIR)/libffi.so.$(FFI_SABLE_LIB_VERSION)

$(DL_DIR)/$(FFI_SABLE_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(FFI_SABLE_SITE)/$(FFI_SABLE_SOURCE)

$(FFI_SABLE_DIR)/.unpacked: $(DL_DIR)/$(FFI_SABLE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FFI_SABLE_SOURCE)
#	for i in $(FFI_SABLE_MAKE_DIR)/patches/*.ffi-sable.patch; do \
#		patch -d $(FFI_SABLE_DIR) -p0 < $$i; \
#	done
	touch $@

$(FFI_SABLE_DIR)/.configured: $(FFI_SABLE_DIR)/.unpacked
	( cd $(FFI_SABLE_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDSHARED="$(TARGET_CC)" \
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
		--disable-debug \
	);
	touch $@

$(FFI_SABLE_BINARY): $(FFI_SABLE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI_SABLE_DIR) \
		$(TARGET_CONFIGURE_OPTS) 

$(FFI_SABLE_STAGING_BINARY): $(FFI_SABLE_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI_SABLE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(FFI_SABLE_TARGET_BINARY): $(FFI_SABLE_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*.so* $(FFI_SABLE_TARGET_DIR)/
	$(TARGET_STRIP) $@

ffi-sable: $(FFI_SABLE_STAGING_BINARY)

ffi-sable-precompiled: uclibc ffi-sable $(FFI_SABLE_TARGET_BINARY)

ffi-sable-source: $(FFI_SABLE_DIR)/.unpacked

ffi-sable-clean:
	-$(MAKE) -C $(FFI_SABLE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*

ffi-sable-uninstall:
	rm -f $(FFI_SABLE_TARGET_DIR)/libffi*.so*

ffi-sable-dirclean:
	rm -rf $(FFI_SABLE_DIR)
