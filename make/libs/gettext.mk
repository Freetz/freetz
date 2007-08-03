GETTEXT_VERSION:=0.16.1
GETTEXT_LIB_VERSION:=8.0.1
GETTEXT_SOURCE:=gettext-$(GETTEXT_VERSION).tar.gz
GETTEXT_SITE:=ftp://ftp.gnu.org/gnu/gettext/
GETTEXT_MAKE_DIR:=$(MAKE_DIR)/libs
GETTEXT_DIR:=$(SOURCE_DIR)/gettext-$(GETTEXT_VERSION)
GETTEXT_BINARY:=$(GETTEXT_DIR)/gettext-runtime/intl/.libs/libintl.so.$(GETTEXT_LIB_VERSION)
GETTEXT_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl.so.$(GETTEXT_LIB_VERSION)
GETTEXT_TARGET_DIR:=root/usr/lib
GETTEXT_TARGET_BINARY:=$(GETTEXT_TARGET_DIR)/libintl.so.$(GETTEXT_LIB_VERSION)

$(DL_DIR)/$(GETTEXT_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(GETTEXT_SITE)/$(GETTEXT_SOURCE)

$(GETTEXT_DIR)/.unpacked: $(DL_DIR)/$(GETTEXT_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(GETTEXT_SOURCE)
#	for i in $(GETTEXT_MAKE_DIR)/patches/*.gettext.patch; do \
#		$(PATCH_TOOL) $(GETTEXT_DIR) $$i; \
#	done
	touch $@

$(GETTEXT_DIR)/.configured: $(GETTEXT_DIR)/.unpacked
	( cd $(GETTEXT_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		CC="$(TARGET_CROSS)gcc" \
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
	        --enable-nls \
	        --disable-java \
		--disable-native-java \
	        --disable-openmp \
		--with-included-gettext \
		--without-libintl-prefix \
		--without-libexpat-prefix \
		--without-emacs \
	);
	touch $@

# We only want libintl
$(GETTEXT_BINARY): $(GETTEXT_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		all

$(GETTEXT_STAGING_BINARY): $(GETTEXT_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(GETTEXT_DIR)/gettext-runtime/intl \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SED) -i -e "s,^libdir=.*,libdir=\'$(TARGET_TOOLCHAIN_STAGING_DIR)/lib\',g" $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libintl.la

$(GETTEXT_TARGET_BINARY): $(GETTEXT_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl*.so* $(GETTEXT_TARGET_DIR)/
	$(TARGET_STRIP) $@

gettext: $(GETTEXT_STAGING_BINARY)

gettext-precompiled: uclibc gettext $(GETTEXT_TARGET_BINARY)

gettext-source: $(GETTEXT_DIR)/.unpacked

gettext-clean:
	-$(MAKE) -C $(GETTEXT_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libgettext*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libintl*

gettext-uninstall:
	rm -f $(GETTEXT_TARGET_DIR)/libintl*.so*

gettext-dirclean:
	rm -rf $(GETTEXT_DIR)
