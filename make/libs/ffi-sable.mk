PACKAGE_LC:=ffi-sable
PACKAGE_UC:=FFI_SABLE
$(PACKAGE_UC)_VERSION:=3325
$(PACKAGE_INIT_LIB)
FFI_SABLE_LIB_VERSION:=4.0.1
FFI_SABLE_SOURCE:=libffi-sable-$(FFI_SABLE_VERSION).tar.gz
FFI_SABLE_SITE:=http://downloads.openwrt.org/sources
FFI_SABLE_DIR:=$(SOURCE_DIR)/libffi-sable-$(FFI_SABLE_VERSION)
FFI_SABLE_BINARY:=$(FFI_SABLE_DIR)/.libs/libffi.so.$(FFI_SABLE_LIB_VERSION)
FFI_SABLE_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi.so.$(FFI_SABLE_LIB_VERSION)
FFI_SABLE_TARGET_BINARY:=$(FFI_SABLE_TARGET_DIR)/libffi.so.$(FFI_SABLE_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


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

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI_SABLE_DIR)

$(FFI_SABLE_STAGING_BINARY): $(FFI_SABLE_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(FFI_SABLE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libffi.la

$(FFI_SABLE_TARGET_BINARY): $(FFI_SABLE_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*.so* $(FFI_SABLE_TARGET_DIR)/
	$(TARGET_STRIP) $@

ffi-sable: $(FFI_SABLE_STAGING_BINARY)

ffi-sable-precompiled: uclibc ffi-sable $(FFI_SABLE_TARGET_BINARY)

ffi-sable-clean:
	-$(MAKE) -C $(FFI_SABLE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libffi*

ffi-sable-uninstall:
	rm -f $(FFI_SABLE_TARGET_DIR)/libffi*.so*

$(PACKAGE_FINI)
