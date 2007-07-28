LIBART_VERSION:=2.3.19
LIBART_LIB_VERSION:=$(LIBART_VERSION)
LIBART_SOURCE:=libart_lgpl-$(LIBART_VERSION).tar.bz2
LIBART_SITE:=http://ftp.gnome.org/pub/gnome/sources/libart_lgpl/2.3/
LIBART_MAKE_DIR:=$(MAKE_DIR)/libs
LIBART_DIR:=$(SOURCE_DIR)/libart_lgpl-$(LIBART_VERSION)
LIBART_BINARY:=$(LIBART_DIR)/.libs/libart_lgpl_2.so.$(LIBART_LIB_VERSION)
LIBART_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart_lgpl_2.so.$(LIBART_LIB_VERSION)
LIBART_TARGET_DIR:=root/usr/lib
LIBART_TARGET_BINARY:=$(LIBART_TARGET_DIR)/libart_lgpl_2.so.$(LIBART_LIB_VERSION)

$(DL_DIR)/$(LIBART_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LIBART_SITE)/$(LIBART_SOURCE)

$(LIBART_DIR)/.unpacked: $(DL_DIR)/$(LIBART_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(LIBART_SOURCE)
	for i in $(LIBART_MAKE_DIR)/patches/*.libart.patch; do \
		$(PATCH_TOOL) $(LIBART_DIR) $$i 1; \
	done
	touch $@

$(LIBART_DIR)/.configured: $(LIBART_DIR)/.unpacked
	( cd $(LIBART_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
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
	);
	touch $@

$(LIBART_BINARY): $(LIBART_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBART_DIR) \
		HOSTCC="$(HOSTCC)" \
		all

$(LIBART_STAGING_BINARY): $(LIBART_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(LIBART_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) 's,-I$${includedir}/libart-2.0,,g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 
	$(SED) 's,-L$${libdir},,g' $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libart-2.0.pc 

$(LIBART_TARGET_BINARY): $(LIBART_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*.so* $(LIBART_TARGET_DIR)
	$(TARGET_STRIP) $@

libart: $(LIBART_STAGING_BINARY)

libart-precompiled: uclibc libart $(LIBART_TARGET_BINARY)

libart-source: $(LIBART_DIR)/.unpacked

libart-clean:
	-$(MAKE) -C $(LIBART_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libart*

libart-uninstall:
	rm -f $(LIBART_TARGET_DIR)/libart*.so*

libart-dirclean:
	rm -rf $(LIBART_DIR)
