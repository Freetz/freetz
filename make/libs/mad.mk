PACKAGE_LC:=mad
PACKAGE_UC:=MAD
$(PACKAGE_UC)_VERSION:=0.15.1b
$(PACKAGE_INIT_LIB)
MAD_LIB_VERSION:=0.2.1
MAD_SOURCE:=libmad-$(MAD_VERSION).tar.gz
MAD_SITE:=http://mesh.dl.sourceforge.net/sourceforge/mad
MAD_DIR:=$(SOURCE_DIR)/libmad-$($(PACKAGE_UC)_VERSION)
MAD_BINARY:=$(MAD_DIR)/.libs/libmad.so.$(MAD_LIB_VERSION)
MAD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad.so.$(MAD_LIB_VERSION)
MAD_TARGET_BINARY:=$(MAD_TARGET_DIR)/libmad.so.$(MAD_LIB_VERSION)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(MAD_DIR)/.configured: $(MAD_DIR)/.unpacked
	( cd $(MAD_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDSHARED="$(TARGET_CC)" \
		ac_cv_c_bigendian=no \
		ac_cv_type_pid_t=yes \
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
		--disable-debugging \
		--enable-speed \
		--enable-fpm="mips" \
	);
	touch $@

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(MAD_DIR)

$(MAD_STAGING_BINARY): $(MAD_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(MAD_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libmad.la

$(MAD_TARGET_BINARY): $(MAD_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*.so* $(MAD_TARGET_DIR)/
	$(TARGET_STRIP) $@

mad: $(MAD_STAGING_BINARY)

mad-precompiled: uclibc mad $(MAD_TARGET_BINARY)

mad-clean:
	-$(MAKE) -C $(MAD_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*

mad-uninstall:
	rm -f $(MAD_TARGET_DIR)/libmad*.so*

$(PACKAGE_FINI)