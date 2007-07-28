FREETYPE_VERSION:=2.3.1
FREETYPE_LIB_VERSION:=6.3.12
FREETYPE_SOURCE:=freetype-$(FREETYPE_VERSION).tar.bz2
FREETYPE_SITE:=http://download.savannah.gnu.org/releases/freetype
FREETYPE_MAKE_DIR:=$(MAKE_DIR)/libs
FREETYPE_DIR:=$(SOURCE_DIR)/freetype-$(FREETYPE_VERSION)
FREETYPE_BINARY:=$(FREETYPE_DIR)/objs/.libs/libfreetype.so.$(FREETYPE_LIB_VERSION)
FREETYPE_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype.so.$(FREETYPE_LIB_VERSION)
FREETYPE_TARGET_DIR:=root/usr/lib
FREETYPE_TARGET_BINARY:=$(FREETYPE_TARGET_DIR)/libfreetype.so.$(FREETYPE_LIB_VERSION)

$(DL_DIR)/$(FREETYPE_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(FREETYPE_SITE)/$(FREETYPE_SOURCE)

$(FREETYPE_DIR)/.unpacked: $(DL_DIR)/$(FREETYPE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(FREETYPE_SOURCE)
	for i in $(FREETYPE_MAKE_DIR)/patches/*.freetype.patch; do \
		$(PATCH_TOOL) $(FREETYPE_DIR) $$i 1; \
	done
	touch $@

$(FREETYPE_DIR)/.configured: $(FREETYPE_DIR)/.unpacked
	( cd $(FREETYPE_DIR); rm -f config.{cache,status} ; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		LD="$(TARGET_LD)" \
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
		--enable-shared \
		--enable-static \
		--disable-rpath \
	);
	touch $@

$(FREETYPE_BINARY): $(FREETYPE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) -C $(FREETYPE_DIR)

$(FREETYPE_STAGING_BINARY): $(FREETYPE_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		-C $(FREETYPE_DIR) install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libfreetype.la
	$(SED) -i -e "s,^prefix=.*,prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)\',g" \
		-e "s,^exec_prefix=.*,exec_prefix=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/usr\',g" \
		-e "s,^includedir=.*,includedir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/include\',g" \
		-e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/freetype-config
					
$(FREETYPE_TARGET_BINARY): $(FREETYPE_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libfreetype*.so* $(FREETYPE_TARGET_DIR)/
	$(TARGET_STRIP) $@

freetype: $(FREETYPE_STAGING_BINARY)

freetype-precompiled: uclibc zlib-precompiled freetype $(FREETYPE_TARGET_BINARY)

freetype-source: $(FREETYPE_DIR)/.unpacked

freetype-clean:
	-$(MAKE) -C $(FREETYPE_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/freetype*

freetype-uninstall:
	rm -f $(FREETYPE_TARGET_DIR)/freetype*.so*

freetype-dirclean:
	rm -rf $(FREETYPE_DIR)
