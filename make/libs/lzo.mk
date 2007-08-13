LZO_VERSION:=2.02
LZO_LIB_VERSION:=2.0.0
LZO_SOURCE:=lzo-$(LZO_VERSION).tar.gz
LZO_SITE:=http://www.oberhumer.com/opensource/lzo/download/
LZO_MAKE_DIR:=$(MAKE_DIR)/libs
LZO_DIR:=$(SOURCE_DIR)/lzo-$(LZO_VERSION)
LZO_BINARY:=$(LZO_DIR)/src/.libs/liblzo2.so.$(LZO_LIB_VERSION)
LZO_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so.$(LZO_LIB_VERSION)
LZO_TARGET_DIR:=root/usr/lib
LZO_TARGET_BINARY:=$(LZO_TARGET_DIR)/liblzo2.so.$(LZO_LIB_VERSION)

$(DL_DIR)/$(LZO_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(LZO_SITE)/$(LZO_SOURCE)

$(LZO_DIR)/.unpacked: $(DL_DIR)/$(LZO_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LZO_SOURCE)
	touch $@

$(LZO_DIR)/.configured: $(LZO_DIR)/.unpacked
	( cd $(LZO_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		./configure \
		--target=mipsel-linux \
		--host=mipsel-linux \
		--build=i386-redhat-linux \
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
		--enable-shared \
		$(DISABLE_LARGEFILE) \
		--disable-libtool-lock \
		--disable-asm \
		--disable-static \
	);
	touch $@

$(LZO_BINARY): $(LZO_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LZO_DIR)


$(LZO_STAGING_BINARY): $(LZO_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(LZO_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/liblzo2.la

$(LZO_TARGET_BINARY): $(LZO_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2*.so* $(LZO_TARGET_DIR)/
	$(TARGET_STRIP) $@

lzo: $(LZO_STAGING_BINARY)

lzo-precompiled: uclibc lzo $(LZO_TARGET_BINARY)

lzo-source: $(LZO_DIR)/.unpacked

lzo-clean:
	-$(MAKE) -C $(LZO_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2*

lzo-uninstall:
	rm -f $(LZO_TARGET_DIR)/liblzo2*.so*

lzo-dirclean:
	rm -rf $(LZO_DIR)
