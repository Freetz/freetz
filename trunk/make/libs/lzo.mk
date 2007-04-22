LZO_VERSION:=2.02
LZO_SOURCE:=lzo-$(LZO_VERSION).tar.gz
LZO_SITE:=http://www.oberhumer.com/opensource/lzo/download/
LZO_DIR:=$(SOURCE_DIR)/lzo-$(LZO_VERSION)
LZO_MAKE_DIR:=$(MAKE_DIR)/libs

$(DL_DIR)/$(LZO_SOURCE):
	wget -P $(DL_DIR) $(LZO_SITE)/$(LZO_SOURCE)

$(LZO_DIR)/.unpacked: $(DL_DIR)/$(LZO_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(LZO_SOURCE)
	touch $@

$(LZO_DIR)/.configured: $(LZO_DIR)/.unpacked
	( cd $(LZO_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC) -static-libgcc" \
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

$(LZO_DIR)/.compiled: $(LZO_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LZO_DIR) \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS) $(CFLAGS_LARGEFILE)"
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so: $(LZO_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(LZO_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
lzo lzo-precompiled:
	@echo 'External compiler used. Trying to copy liblzo...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/liblzo*.so* root/usr/lib/
else
lzo: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo2.so
lzo-precompiled: lzo
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzo*.so* root/usr/lib/
endif

lzo-source: $(LZO_DIR)/.unpacked

lzo-clean:
	-$(MAKE) -C $(LZO_DIR) clean

lzo-dirclean:
	rm -rf $(LZO_DIR)
