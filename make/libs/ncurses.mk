PACKAGE_LC:=ncurses
PACKAGE_UC:=NCURSES
$(PACKAGE_UC)_VERSION:=5.6
$(PACKAGE_INIT_LIB)
NCURSES_LIB_VERSION:=$(NCURSES_VERSION)
NCURSES_SOURCE:=ncurses-$(NCURSES_VERSION).tar.gz
NCURSES_SITE:=http://ftp.gnu.org/pub/gnu/ncurses
NCURSES_NCURSES_BINARY:=$(NCURSES_DIR)/lib/libncurses.so.$(NCURSES_LIB_VERSION)
NCURSES_NCURSES_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so.$(NCURSES_LIB_VERSION)
NCURSES_NCURSES_TARGET_BINARY:=$(NCURSES_TARGET_DIR)/libncurses.so.$(NCURSES_LIB_VERSION)
NCURSES_FORM_BINARY:=$(NCURSES_DIR)/lib/libform.so.$(NCURSES_LIB_VERSION)
NCURSES_FORM_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform.so.$(NCURSES_LIB_VERSION)
NCURSES_FORM_TARGET_BINARY:=$(NCURSES_TARGET_DIR)/libform.so.$(NCURSES_LIB_VERSION)
NCURSES_MENU_BINARY:=$(NCURSES_DIR)/lib/libmenu.so.$(NCURSES_LIB_VERSION)
NCURSES_MENU_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu.so.$(NCURSES_LIB_VERSION)
NCURSES_MENU_TARGET_BINARY:=$(NCURSES_TARGET_DIR)/libmenu.so.$(NCURSES_LIB_VERSION)
NCURSES_PANEL_BINARY:=$(NCURSES_DIR)/lib/libpanel.so.$(NCURSES_LIB_VERSION)
NCURSES_PANEL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel.so.$(NCURSES_LIB_VERSION)
NCURSES_PANEL_TARGET_BINARY:=$(NCURSES_TARGET_DIR)/libpanel.so.$(NCURSES_LIB_VERSION)

NCURSES_DS_CONFIG_FILE:=$(NCURSES_MAKE_DIR)/.ds_config_ncurses
NCURSES_DS_CONFIG_TEMP:=$(NCURSES_MAKE_DIR)/.ds_config_ncurses.temp

$(NCURSES_DS_CONFIG_FILE): $(TOPDIR)/.config
	grep 'DS_LIB_libterminfo_.*=y' $(TOPDIR)/.config | grep -v showall > $(NCURSES_DS_CONFIG_TEMP)
	diff -q $(NCURSES_DS_CONFIG_TEMP) $(NCURSES_DS_CONFIG_FILE) || \
		cp $(NCURSES_DS_CONFIG_TEMP) $(NCURSES_DS_CONFIG_FILE)
	rm -f $(NCURSES_DS_CONFIG_TEMP)

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)


$(NCURSES_DIR)/.configured: $(NCURSES_DIR)/.unpacked
	( cd $(NCURSES_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		PATH="$(TARGET_TOOLCHAIN_PATH)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
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

$($(PACKAGE_UC)_NCURSES_BINARY) \
$($(PACKAGE_UC)_FORM_BINARY) \
$($(PACKAGE_UC)_MENU_BINARY) \
$($(PACKAGE_UC)_PANEL_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE1) -C $(NCURSES_DIR) \
		libs panel menu form headers

$(NCURSES_NCURSES_STAGING_BINARY) \
$(NCURSES_FORM_STAGING_BINARY) \
$(NCURSES_MENU_STAGING_BINARY) \
$(NCURSES_PANEL_STAGING_BINARY): \
		$(NCURSES_NCURSES_BINARY) \
		$(NCURSES_FORM_BINARY) \
		$(NCURSES_MENU_BINARY) \
		$(NCURSES_PANEL_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE1) -C $(NCURSES_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install.libs install.data


# Make sure that a changed DS-mod option forces the target terminfo directory
# to be build from scratch.
$(NCURSES_DIR)/.targetdata: $(NCURSES_DS_CONFIG_FILE)
	rm -rf $(NCURSES_TARGET_DIR)/../share/tabset $(NCURSES_TARGET_DIR)/../share/terminfo
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset \
		$(NCURSES_TARGET_DIR)/../share/
	( . $(NCURSES_DS_CONFIG_FILE); \
		for O in `cd $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo; find . -type f -o -type l`; do \
			ID="`basename "$$O" | sed -e 's/\./dot/g' -e 's/-/minus/g' -e 's/\+/plus/g'`"; \
			EV="`echo -n '$${'; echo -n DS_LIB_libterminfo_$$ID; echo ':-n}'`"; \
			RS="`eval echo $$EV`"; \
			if [ "$$RS" = "y" ]; then \
				DIRNAME=`dirname $$O`; \
				mkdir -p $(NCURSES_TARGET_DIR)/../share/terminfo/$$DIRNAME; \
				cp -va $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/$$O $(NCURSES_TARGET_DIR)/../share/terminfo/$$DIRNAME/; \
			fi; \
		done )
	touch $@

$(NCURSES_NCURSES_TARGET_BINARY): $(NCURSES_NCURSES_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset \
		$(NCURSES_TARGET_DIR)/../share/
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(NCURSES_FORM_TARGET_BINARY): $(NCURSES_FORM_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(NCURSES_MENU_TARGET_BINARY): $(NCURSES_MENU_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$(NCURSES_PANEL_TARGET_BINARY): $(NCURSES_PANEL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

ifeq ($(strip $(DS_LIB_libncurses)),y)
ncurses-ncurses: $(NCURSES_NCURSES_STAGING_BINARY)
ncurses-ncurses-precompiled: $(NCURSES_DIR)/.targetdata $(NCURSES_NCURSES_TARGET_BINARY)
else
ncurses-ncurses ncurses-ncurses-precompiled:
endif

ifeq ($(strip $(DS_LIB_libform)),y)
ncurses-form: $(NCURSES_FORM_STAGING_BINARY)
ncurses-form-precompiled: $(NCURSES_FORM_TARGET_BINARY)
else
ncurses-form ncurses-form-precompiled:
endif

ifeq ($(strip $(DS_LIB_libmenu)),y)
ncurses-menu: $(NCURSES_MENU_STAGING_BINARY)
ncurses-menu-precompiled: $(NCURSES_MENU_TARGET_BINARY)
else
ncurses-menu ncurses-menu-precompiled:
endif

ifeq ($(strip $(DS_LIB_libpanel)),y)
ncurses-panel: $(NCURSES_PANEL_STAGING_BINARY)
ncurses-panel-precompiled: $(NCURSES_PANEL_TARGET_BINARY)
else
ncurses-panel ncurses-panel-precompiled:
endif

ncurses: ncurses-ncurses ncurses-form ncurses-menu ncurses-panel

ncurses-precompiled: uclibc ncurses ncurses-ncurses-precompiled ncurses-form-precompiled ncurses-menu-precompiled ncurses-panel-precompiled

ncurses-clean:
	-$(MAKE) -C $(NCURSES_DIR) clean
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu*
	rm -f $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel*
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset
	rm -rf $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo

ncurses-uninstall:
	rm -f $(NCURSES_TARGET_DIR)/libncurses*.so*
	rm -f $(NCURSES_TARGET_DIR)/libform*.so*
	rm -f $(NCURSES_TARGET_DIR)/libmenu*.so*
	rm -f $(NCURSES_TARGET_DIR)/libpanel*.so*
	rm -rf $(NCURSES_TARGET_DIR)/../share/tabset
	rm -rf $(NCURSES_TARGET_DIR)/../share/terminfo

$(PACKAGE_FINI)
