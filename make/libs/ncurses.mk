$(eval $(call PKG_INIT_LIB, 5.6))
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=ncurses-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://ftp.gnu.org/pub/gnu/ncurses
$(PKG)_$(PKG)_BINARY:=$($(PKG)_DIR)/lib/libncurses.so.$($(PKG)_LIB_VERSION)
$(PKG)_$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses.so.$($(PKG)_LIB_VERSION)
$(PKG)_$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libncurses.so.$($(PKG)_LIB_VERSION)
$(PKG)_FORM_BINARY:=$($(PKG)_DIR)/lib/libform.so.$($(PKG)_LIB_VERSION)
$(PKG)_FORM_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform.so.$($(PKG)_LIB_VERSION)
$(PKG)_FORM_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libform.so.$($(PKG)_LIB_VERSION)
$(PKG)_MENU_BINARY:=$($(PKG)_DIR)/lib/libmenu.so.$($(PKG)_LIB_VERSION)
$(PKG)_MENU_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu.so.$($(PKG)_LIB_VERSION)
$(PKG)_MENU_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libmenu.so.$($(PKG)_LIB_VERSION)
$(PKG)_PANEL_BINARY:=$($(PKG)_DIR)/lib/libpanel.so.$($(PKG)_LIB_VERSION)
$(PKG)_PANEL_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel.so.$($(PKG)_LIB_VERSION)
$(PKG)_PANEL_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libpanel.so.$($(PKG)_LIB_VERSION)

$(PKG)_CONFIGURE_OPTIONS += --enable-echo
$(PKG)_CONFIGURE_OPTIONS += --enable-const
$(PKG)_CONFIGURE_OPTIONS += --enable-overwrite
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-ada
$(PKG)_CONFIGURE_OPTIONS += --without-cxx
$(PKG)_CONFIGURE_OPTIONS += --without-cxx-binding
$(PKG)_CONFIGURE_OPTIONS += --without-debug
$(PKG)_CONFIGURE_OPTIONS += --without-profile
$(PKG)_CONFIGURE_OPTIONS += --without-progs
$(PKG)_CONFIGURE_OPTIONS += --with-normal
$(PKG)_CONFIGURE_OPTIONS += --with-shared
$(PKG)_CONFIGURE_OPTIONS += --with-terminfo-dirs="/usr/share/terminfo"
$(PKG)_CONFIGURE_OPTIONS += --with-default-terminfo-dir="/usr/share/terminfo"

$(PKG)_DS_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/.ds_config_ncurses
$(PKG)_DS_CONFIG_TEMP:=$($(PKG)_MAKE_DIR)/.ds_config_ncurses.temp

$($(PKG)_DS_CONFIG_FILE): $(TOPDIR)/.config
	@grep 'DS_LIB_libterminfo_.*=y' $(TOPDIR)/.config | grep -v showall > $(NCURSES_DS_CONFIG_TEMP)
	@diff -q $(NCURSES_DS_CONFIG_TEMP) $(NCURSES_DS_CONFIG_FILE) || \
		cp $(NCURSES_DS_CONFIG_TEMP) $(NCURSES_DS_CONFIG_FILE)
	@rm -f $(NCURSES_DS_CONFIG_TEMP)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_NCURSES_BINARY) \
$($(PKG)_FORM_BINARY) \
$($(PKG)_MENU_BINARY) \
$($(PKG)_PANEL_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(NCURSES_DIR) \
		libs panel menu form headers

$($(PKG)_NCURSES_STAGING_BINARY) \
$($(PKG)_FORM_STAGING_BINARY) \
$($(PKG)_MENU_STAGING_BINARY) \
$($(PKG)_PANEL_STAGING_BINARY): \
		$($(PKG)_NCURSES_BINARY) \
		$($(PKG)_FORM_BINARY) \
		$($(PKG)_MENU_BINARY) \
		$($(PKG)_PANEL_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(NCURSES_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install.libs install.data


# Make sure that a changed DS-mod option forces the target terminfo directory
# to be build from scratch.
$($(PKG)_DIR)/.targetdata: $($(PKG)_DS_CONFIG_FILE)
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

$($(PKG)_NCURSES_TARGET_BINARY): $($(PKG)_NCURSES_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset \
		$(NCURSES_TARGET_DIR)/../share/
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_FORM_TARGET_BINARY): $($(PKG)_FORM_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_MENU_TARGET_BINARY): $($(PKG)_MENU_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

$($(PKG)_PANEL_TARGET_BINARY): $($(PKG)_PANEL_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel*.so* $(NCURSES_TARGET_DIR)/
	$(TARGET_STRIP) $@

ifeq ($(strip $(DS_LIB_libncurses)),y)
ncurses-ncurses: $($(PKG)_NCURSES_STAGING_BINARY)
ncurses-ncurses-precompiled: $($(PKG)_DIR)/.targetdata $($(PKG)_NCURSES_TARGET_BINARY)
else
ncurses-ncurses ncurses-ncurses-precompiled:
endif

ifeq ($(strip $(DS_LIB_libform)),y)
ncurses-form: $($(PKG)_FORM_STAGING_BINARY)
ncurses-form-precompiled: $($(PKG)_FORM_TARGET_BINARY)
else
ncurses-form ncurses-form-precompiled:
endif

ifeq ($(strip $(DS_LIB_libmenu)),y)
ncurses-menu: $($(PKG)_MENU_STAGING_BINARY)
ncurses-menu-precompiled: $($(PKG)_MENU_TARGET_BINARY)
else
ncurses-menu ncurses-menu-precompiled:
endif

ifeq ($(strip $(DS_LIB_libpanel)),y)
ncurses-panel: $($(PKG)_PANEL_STAGING_BINARY)
ncurses-panel-precompiled: $($(PKG)_PANEL_TARGET_BINARY)
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

$(PKG_FINISH)
