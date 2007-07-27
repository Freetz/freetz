MAD_VERSION:=0.15.1b
MAD_LIB_VERSION:=0.2.1
MAD_SOURCE:=libmad-$(MAD_VERSION).tar.gz
MAD_SITE:=http://mesh.dl.sourceforge.net/sourceforge/mad
MAD_MAKE_DIR:=$(MAKE_DIR)/libs
MAD_DIR:=$(SOURCE_DIR)/libmad-$(MAD_VERSION)
MAD_BINARY:=$(MAD_DIR)/.libs/libmad.so.$(MAD_LIB_VERSION)
MAD_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad.so.$(MAD_LIB_VERSION)
MAD_TARGET_DIR:=root/usr/lib
MAD_TARGET_BINARY:=$(MAD_TARGET_DIR)/libmad.so.$(MAD_LIB_VERSION)


$(DL_DIR)/$(MAD_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(MAD_SITE)/$(MAD_SOURCE)

$(MAD_DIR)/.unpacked: $(DL_DIR)/$(MAD_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MAD_SOURCE)
#	for i in $(MAD_MAKE_DIR)/patches/*.mad.patch; do \
#		patch -d $(MAD_DIR) -p0 < $$i; \
#	done
	touch $@

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

$(MAD_BINARY): $(MAD_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(MAD_DIR) \

$(MAD_STAGING_BINARY): $(MAD_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(MAD_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(MAD_TARGET_BINARY): $(MAD_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*.so* $(MAD_TARGET_DIR)/
	$(TARGET_STRIP) $@

mad: $(MAD_STAGING_BINARY)

mad-precompiled: uclibc mad $(MAD_TARGET_BINARY)

mad-source: $(MAD_DIR)/.unpacked

mad-clean:
	-$(MAKE) -C $(MAD_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmad*

mad-uninstall:
	rm -f $(MAD_TARGET_DIR)/libmad*.so*

mad-dirclean:
	rm -rf $(MAD_DIR)
