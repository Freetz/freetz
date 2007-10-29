PACKAGE_LC:=readline
PACKAGE_UC:=READLINE
$(PACKAGE_UC)_VERSION:=5.2
$(PACKAGE_INIT_LIB)
READLINE_LIB_VERSION:=$(READLINE_VERSION)
READLINE_SOURCE:=readline-$(READLINE_VERSION).tar.gz
READLINE_SITE:=ftp://ftp.cwru.edu/pub/bash
READLINE_READLINE_BINARY:=$(READLINE_DIR)/shlib/libreadline.so.$(READLINE_LIB_VERSION)
READLINE_HISTORY_BINARY:=$(READLINE_DIR)/shlib/libhistory.so.$(READLINE_LIB_VERSION)
READLINE_STAGING_READLINE_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline.so.$(READLINE_LIB_VERSION)
READLINE_STAGING_HISTORY_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory.so.$(READLINE_LIB_VERSION)
READLINE_TARGET_READLINE_BINARY:=$(READLINE_TARGET_DIR)/libreadline.so.$(READLINE_LIB_VERSION)
READLINE_TARGET_HISTORY_BINARY:=$(READLINE_TARGET_DIR)/libhistory.so.$(READLINE_LIB_VERSION)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(READLINE_DIR)/.configured: $(READLINE_DIR)/.unpacked
	( cd $(READLINE_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		bash_cv_func_sigsetjmp=yes \
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
	);
	touch $@

$($(PACKAGE_UC)_READLINE_BINARY) $($(PACKAGE_UC)_HISTORY_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(READLINE_DIR)

$(READLINE_STAGING_READLINE_BINARY) $(READLINE_STAGING_HISTORY_BINARY): \
		$(READLINE_READLINE_BINARY) $(READLINE_HISTORY_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(READLINE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(READLINE_TARGET_READLINE_BINARY): $(READLINE_STAGING_READLINE_BINARY)
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libreadline*.so* $(READLINE_TARGET_DIR)/
	$(TARGET_STRIP) $@
	
$(READLINE_TARGET_HISTORY_BINARY):  $(READLINE_STAGING_HISTORY_BINARY)
	chmod 755 $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libhistory*.so* $(READLINE_TARGET_DIR)/
	$(TARGET_STRIP) $@

readline: $(READLINE_STAGING_READLINE_BINARY) $(READLINE_STAGING_HISTORY_BINARY)

readline-precompiled: uclibc ncurses-precompiled readline \
		$(READLINE_TARGET_READLINE_BINARY) $(READLINE_TARGET_HISTORY_BINARY)

readline-clean:
	$(MAKE) DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" -C $(READLINE_DIR) uninstall
	-$(MAKE) -C $(READLINE_DIR) clean

readline-uninstall:
	rm -f $(READLINE_TARGET_DIR)/libreadline*.so*
	rm -f $(READLINE_TARGET_DIR)/libhistory*.so*

$(PACKAGE_FINI)
