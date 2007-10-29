PACKAGE_LC:=ncurses
PACKAGE_UC:=NCURSES
$(PACKAGE_UC)_VERSION:=5.6
$(PACKAGE_INIT_LIB)
$(PACKAGE_UC)_LIB_VERSION:=$($(PACKAGE_UC)_VERSION)
$(PACKAGE_UC)_SOURCE:=ncurses-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://ftp.gnu.org/pub/gnu/ncurses
$(PACKAGE_UC)_$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/lib/libncurses.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_$(PACKAGE_UC)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libncurses.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_FORM_BINARY:=$($(PACKAGE_UC)_DIR)/lib/libform.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_FORM_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_FORM_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libform.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_MENU_BINARY:=$($(PACKAGE_UC)_DIR)/lib/libmenu.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_MENU_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_MENU_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libmenu.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_PANEL_BINARY:=$($(PACKAGE_UC)_DIR)/lib/libpanel.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_PANEL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel.so.$($(PACKAGE_UC)_LIB_VERSION)
$(PACKAGE_UC)_PANEL_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/libpanel.so.$($(PACKAGE_UC)_LIB_VERSION)

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-echo
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-const
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --enable-overwrite
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --disable-rpath
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-ada
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-cxx
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-cxx-binding
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-debug
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-profile
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --without-progs
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-normal
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-shared
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-terminfo-dirs="/usr/share/terminfo"
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-default-terminfo-dir="/usr/share/terminfo"

$(PACKAGE_UC)_DS_CONFIG_FILE:=$($(PACKAGE_UC)_MAKE_DIR)/.ds_config_ncurses
$(PACKAGE_UC)_DS_CONFIG_TEMP:=$($(PACKAGE_UC)_MAKE_DIR)/.ds_config_ncurses.temp

$($(PACKAGE_UC)_DS_CONFIG_FILE): $(TOPDIR)/.config
	@grep 'DS_LIB_libterminfo_.*=y' $(TOPDIR)/.config | grep -v showall > $(NCURSES_DS_CONFIG_TEMP)
	@diff -q $(NCURSES_DS_CONFIG_TEMP) $(NCURSES_DS_CONFIG_FILE) || \
		cp $(NCURSES_DS_CONFIG_TEMP) $(NCURSES_DS_CONFIG_FILE)
	@rm -f $(NCURSES_DS_CONFIG_TEMP)


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_NCURSES_BINARY) \
$($(PACKAGE_UC)_FORM_BINARY) \
$($(PACKAGE_UC)_MENU_BINARY) \
$($(PACKAGE_UC)_PANEL_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(NCURSES_DIR) \
		AR="$(TARGET_CROSS)ar rv" \
		libs panel menu form headers

$($(PACKAGE_UC)_NCURSES_STAGING_BINARY) \
$($(PACKAGE_UC)_FORM_STAGING_BINARY) \
$($(PACKAGE_UC)_MENU_STAGING_BINARY) \
$($(PACKAGE_UC)_PANEL_STAGING_BINARY): \
		$($(PACKAGE_UC)_NCURSES_BINARY) \
		$($(PACKAGE_UC)_FORM_BINARY) \
		$($(PACKAGE_UC)_MENU_BINARY) \
		$($(PACKAGE_UC)_PANEL_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(NCURSES_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install.libs install.data


# Make sure that a changed DS-mod option forces the target terminfo directory
# to be build from scratch.
$($(PACKAGE_UC)_DIR)/.targetdata: $($(PACKAGE_UC)_DS_CONFIG_FILE)
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

$($(PACKAGE_UC)_NCURSES_TARGET_BINARY): $($(PACKAGE_UC)_NCURSES_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset \
		$(NCURSES_TARGET_DIR)/../share/
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PACKAGE_UC)_FORM_TARGET_BINARY): $($(PACKAGE_UC)_FORM_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PACKAGE_UC)_MENU_TARGET_BINARY): $($(PACKAGE_UC)_MENU_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PACKAGE_UC)_PANEL_TARGET_BINARY): $($(PACKAGE_UC)_PANEL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

ifeq ($(strip $(DS_LIB_libncurses)),y)
ncurses-ncurses: $($(PACKAGE_UC)_NCURSES_STAGING_BINARY)
ncurses-ncurses-precompiled: $($(PACKAGE_UC)_DIR)/.targetdata $($(PACKAGE_UC)_NCURSES_TARGET_BINARY)
else
ncurses-ncurses ncurses-ncurses-precompiled:
endif

ifeq ($(strip $(DS_LIB_libform)),y)
ncurses-form: $($(PACKAGE_UC)_FORM_STAGING_BINARY)
ncurses-form-precompiled: $($(PACKAGE_UC)_FORM_TARGET_BINARY)
else
ncurses-form ncurses-form-precompiled:
endif

ifeq ($(strip $(DS_LIB_libmenu)),y)
ncurses-menu: $($(PACKAGE_UC)_MENU_STAGING_BINARY)
ncurses-menu-precompiled: $($(PACKAGE_UC)_MENU_TARGET_BINARY)
else
ncurses-menu ncurses-menu-precompiled:
endif

ifeq ($(strip $(DS_LIB_libpanel)),y)
ncurses-panel: $($(PACKAGE_UC)_PANEL_STAGING_BINARY)
ncurses-panel-precompiled: $($(PACKAGE_UC)_PANEL_TARGET_BINARY)
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
