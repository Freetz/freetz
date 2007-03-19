READLINE_VERSION:=5.2
READLINE_SOURCE:=readline-$(READLINE_VERSION).tar.gz
READLINE_SITE:=ftp://ftp.cwru.edu/pub/bash
READLINE_DIR:=$(SOURCE_DIR)/readline-$(READLINE_VERSION)
READLINE_MAKE_DIR:=$(MAKE_DIR)/libs

$(DL_DIR)/$(READLINE_SOURCE):
	wget -P $(DL_DIR) $(READLINE_SITE)/$(READLINE_SOURCE)

$(READLINE_DIR)/.unpacked: $(DL_DIR)/$(READLINE_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(READLINE_SOURCE)
	touch $@

$(READLINE_DIR)/.configured: ncurses $(READLINE_DIR)/.unpacked
	( cd $(READLINE_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-static-libgcc -L$(TARGET_MAKE_PATH)/../usr/lib" \
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
		--enable-shared \
		--enable-static \
		--disable-multibyte \
		--without-purify \
		--with-curses \
		$(DISABLE_LARGEFILE) \
	);
	touch $@

$(READLINE_DIR)/.compiled: $(READLINE_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(READLINE_DIR)
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline.so \
 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory.so: $(READLINE_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(READLINE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
readline readline-precompiled:
	@echo 'External compiler used. Skipping readline...'
ifeq ($(strip $(DS_LIB_libreadline)),y)
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libreadline*.so* root/usr/lib/
endif
ifeq ($(strip $(DS_LIB_libhistory)),y)
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libhistory*.so* root/usr/lib/
endif
else

readline: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline.so $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory.so
readline-precompiled: readline
	chmod 0644 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so*
	chmod 0644 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so*
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so*
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so*
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libreadline*.so* root/usr/lib/
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libhistory*.so* root/usr/lib/
endif

readline-source: $(READLINE_DIR)/.unpacked

readline-clean:
	-$(MAKE) -C $(READLINE_DIR) clean

readline-dirclean: readline-stagingclean
	rm -rf $(READLINE_DIR)

readline-stagingclean:
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so*
	rm -f $(READLINE_DIR)/.installed

