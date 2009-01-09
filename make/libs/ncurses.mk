$(call PKG_INIT_LIB, 5.6)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
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
$(PKG)_TERMINFO_STAGING_DIR:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo
$(PKG)_TERMINFO_TARGET_DIR:=$(ROOT_DIR)/usr/share/terminfo

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

$($(PKG)_TERMINFO_STAGING_DIR)/.installed: $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(NCURSES_DIR)/misc \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		all install
	touch $@

$($(PKG)_TERMINFO_TARGET_DIR)/.installed: $($(PKG)_TERMINFO_STAGING_DIR)/.installed
	rm -rf $(NCURSES_TARGET_DIR)/../share/tabset $(NCURSES_TERMINFO_TARGET_DIR)
	mkdir -p $(NCURSES_TERMINFO_TARGET_DIR) $(NCURSES_TARGET_DIR)/../share
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo/* $(NCURSES_TERMINFO_TARGET_DIR)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset $(NCURSES_TARGET_DIR)/../share
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

$(pkg)-ncurses: $($(PKG)_NCURSES_STAGING_BINARY) 
$(pkg)-ncurses-precompiled: $($(PKG)_NCURSES_TARGET_BINARY) $(pkg)-terminfo

$(pkg)-form: $($(PKG)_FORM_STAGING_BINARY)
$(pkg)-form-precompiled: $($(PKG)_FORM_TARGET_BINARY)

$(pkg)-menu: $($(PKG)_MENU_STAGING_BINARY)
$(pkg)-menu-precompiled: $($(PKG)_MENU_TARGET_BINARY)

$(pkg)-panel: $($(PKG)_PANEL_STAGING_BINARY)
$(pkg)-panel-precompiled: $($(PKG)_PANEL_TARGET_BINARY)

$(pkg): $(pkg)-ncurses $(pkg)-form $(pkg)-menu $(pkg)-panel
$(pkg)-precompiled: $(pkg)-ncurses-precompiled $(pkg)-form-precompiled $(pkg)-menu-precompiled $(pkg)-panel-precompiled

$(pkg)-terminfo: $($(PKG)_TERMINFO_TARGET_DIR)/.installed

$(pkg)-terminfo-precompiled: $(pkg)-terminfo

$(pkg)-terminfo-clean:
	rm -rf $(NCURSES_TARGET_DIR)/../share/tabset $(NCURSES_TERMINFO_TARGET_DIR)

$(pkg)-clean: $(pkg)-terminfo-clean
	-$(MAKE) -C $(NCURSES_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libncurses*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libform*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libmenu*
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpanel*
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/tabset
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/terminfo

$(pkg)-uninstall:
	$(RM) $(NCURSES_TARGET_DIR)/libncurses*.so*
	$(RM) $(NCURSES_TARGET_DIR)/libform*.so*
	$(RM) $(NCURSES_TARGET_DIR)/libmenu*.so*
	$(RM) $(NCURSES_TARGET_DIR)/libpanel*.so*
	$(RM) -r $(NCURSES_TARGET_DIR)/../share/tabset
	$(RM) -r $(NCURSES_TARGET_DIR)/../share/terminfo

$(PKG_FINISH)
