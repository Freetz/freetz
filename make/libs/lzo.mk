PACKAGE_LC:=lzo
PACKAGE_UC:=LZO
$(PACKAGE_UC)_VERSION:=2.02
$(PACKAGE_INIT_LIB)
LZO_LIB_VERSION:=2.0.0
LZO_SOURCE:=lzo-$(LZO_VERSION).tar.gz
LZO_SITE:=http://www.oberhumer.com/opensource/lzo/download/
LZO_BINARY:=$(LZO_DIR)/src/.libs/liblzo2.so.$(LZO_LIB_VERSION)
LZO_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so.$(LZO_LIB_VERSION)
LZO_TARGET_BINARY:=$(LZO_TARGET_DIR)/liblzo2.so.$(LZO_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


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

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
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
lzo-clean:
	-$(MAKE) -C $(LZO_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2*

lzo-uninstall:
	rm -f $(LZO_TARGET_DIR)/liblzo2*.so*

$(PACKAGE_FINI)