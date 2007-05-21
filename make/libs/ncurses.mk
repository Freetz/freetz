NCURSES_VERSION:=5.5
NCURSES_SOURCE:=ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_SITE:=http://ftp.gnu.org/pub/gnu/ncurses
NCURSES_DIR:=$(SOURCE_DIR)/ncurses-$(NCURSES_VERSION)
NCURSES_MAKE_DIR:=$(MAKE_DIR)/libs


$(DL_DIR)/$(NCURSES_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(NCURSES_SITE)/$(NCURSES_SOURCE)

$(NCURSES_DIR)/.unpacked: $(DL_DIR)/$(NCURSES_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(NCURSES_SOURCE)
	for i in $(NCURSES_MAKE_DIR)/patches/*.ncurses.patch; do \
		patch -d $(NCURSES_DIR) -p0 < $$i; \
	done
	touch $@

$(NCURSES_DIR)/.configured: $(NCURSES_DIR)/.unpacked
	( cd $(NCURSES_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib -static-libgcc" \
		ac_cv_linux_vers="2" \
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
		--enable-echo \
		--enable-const \
		--enable-overwrite \
		--disable-rpath \
		--without-ada \
		--without-cxx \
		--without-cxx-binding \
		--without-debug \
		--without-profile \
		--without-progs \
		--with-normal \
		--with-shared \
		--with-terminfo-dirs=/usr/share/terminfo \
		--with-default-terminfo-dir=/usr/share/terminfo \
	);
	touch $@

$(NCURSES_DIR)/.compiled: $(NCURSES_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE1) \
		-C $(NCURSES_DIR) $(TARGET_CONFIGURE_OPTS) \
		libs panel menu form headers
	touch $@

$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so: $(NCURSES_DIR)/.compiled
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE1) \
		-C $(NCURSES_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install.libs install.data
	touch -c $@

ifeq ($(strip $(DS_EXTERNAL_COMPILER)),y)
ncurses ncurses-precompiled:
	@echo 'External compiler used. Skipping ncurses...'
	cp -a $(TARGET_MAKE_PATH)/../usr/lib/libncurses*.so* root/usr/lib/
else
ncurses: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so
ncurses-precompiled: uclibc ncurses
	$(TARGET_STRIP) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*.so*
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*.so* root/usr/lib/
endif

ncurses-source: $(NCURSES_DIR)/.unpacked

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) clean
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*
	rm -rf root/usr/lib/libncurses*.so*
ncurses-dirclean:
	rm -rf $(NCURSES_DIR)
