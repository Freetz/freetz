SCREEN_VERSION:=4.0.3
SCREEN_SOURCE:=screen-$(SCREEN_VERSION).tar.gz
SCREEN_SITE:=http://ftp.uni-erlangen.de/pub/utilities/screen
SCREEN_MAKE_DIR:=$(MAKE_DIR)/screen
SCREEN_DIR:=$(SOURCE_DIR)/screen-$(SCREEN_VERSION)
SCREEN_BINARY:=$(SCREEN_DIR)/screen
SCREEN_PKG_VERSION:=0.2
SCREEN_PKG_SOURCE:=screen-$(SCREEN_VERSION)-dsmod-$(SCREEN_PKG_VERSION).tar.bz2
SCREEN_PKG_SITE:=http://dsmod.magenbrot.net
SCREEN_TARGET_DIR:=$(PACKAGES_DIR)/screen-$(SCREEN_VERSION)
SCREEN_TARGET_BINARY:=$(SCREEN_TARGET_DIR)/root/usr/bin/screen.bin


$(DL_DIR)/$(SCREEN_SOURCE): | $(DL_DIR)
	wget -P $(DL_DIR) $(SCREEN_SITE)/$(SCREEN_SOURCE)

$(DL_DIR)/$(SCREEN_PKG_SOURCE): | $(DL_DIR)
	@$(DL_TOOL) $(DL_DIR) $(TOPDIR)/.config $(SCREEN_PKG_SOURCE) $(SCREEN_PKG_SITE)

$(SCREEN_DIR)/.unpacked: $(DL_DIR)/$(SCREEN_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(SCREEN_SOURCE)
	for i in $(SCREEN_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(SCREEN_DIR) $$i; \
	done
	touch $@

$(SCREEN_DIR)/.configured: $(SCREEN_DIR)/.unpacked
	( cd $(SCREEN_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_MAKE_PATH)/../usr/include" \
		LDFLAGS="-L$(TARGET_MAKE_PATH)/../usr/lib" \
		$(foreach flag,rename fchmod fchown strerror lstat _exit utimes vsnprintf getcwd setlocale strftime,ac_cv_func_$(flag)=yes ) \
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
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		--enable-shared \
		--disable-static \
		--disable-socket-dir \
		--with-sys-screenrc=/mod/etc/screenrc \
	);
	touch $@

$(SCREEN_BINARY): $(SCREEN_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) -C $(SCREEN_DIR)

$(SCREEN_TARGET_BINARY): $(SCREEN_BINARY)
	mkdir -p $(SCREEN_TARGET_DIR)/root/usr/share/terminfo/{a,d,l,r,s,v,x}
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/a/ansi \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/a/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/d/dumb \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/d/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/l/linux \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/l/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/r/rxvt \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/r/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/s/{sun,screen-w,screen} \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/s/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/v/{vt52,vt100,vt102,vt200,vt220} \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/v/
	cp $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/x/{xterm,xterm-color,xterm-xfree86} \
		$(SCREEN_TARGET_DIR)/root/usr/share/terminfo/x/
	$(INSTALL_BINARY_STRIP)

$(PACKAGES_DIR)/.screen-$(SCREEN_VERSION): $(DL_DIR)/$(SCREEN_PKG_SOURCE) | $(PACKAGES_DIR)
	@tar -C $(PACKAGES_DIR) -xjf $(DL_DIR)/$(SCREEN_PKG_SOURCE)
	@touch $@

screen: $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)

screen-package: $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)
	tar -C $(PACKAGES_DIR) $(VERBOSE) --exclude .svn -cjf $(PACKAGES_BUILD_DIR)/$(SCREEN_PKG_SOURCE) screen-$(SCREEN_VERSION)

screen-precompiled: uclibc ncurses-precompiled screen $(SCREEN_TARGET_BINARY)

screen-source: $(SCREEN_DIR)/.unpacked $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)

screen-clean:
	-$(MAKE) -C $(SCREEN_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(SCREEN_PKG_SOURCE)

screen-dirclean:
	rm -rf $(SCREEN_DIR)
	rm -rf $(PACKAGES_DIR)/screen-$(SCREEN_VERSION)
	rm -f $(PACKAGES_DIR)/.screen-$(SCREEN_VERSION)

screen-uninstall:
	rm -f $(SCREEN_TARGET_BINARY)
	rm -rf $(SCREEN_TARGET_DIR)/root/usr/share/terminfo/{a,d,l,r,s,v,x}

screen-list:
ifeq ($(strip $(DS_PACKAGE_SCREEN)),y)
	@echo "S99screen-$(SCREEN_VERSION)" >> .static
else
	@echo "S99screen-$(SCREEN_VERSION)" >> .dynamic
endif
