$(call PKG_INIT_BIN, 4.6.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.ibiblio.org/pub/Linux/utils/file/managers/mc/
$(PKG)_HELP:=$($(PKG)_MAKE_DIR)/files/root/usr/share/mc/mc.hlp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mc.bin
$(PKG)_TARGET_HELP:=$($(PKG)_DEST_DIR)/usr/share/mc/mc.hlp

$(PKG)_DEPENDS_ON := glib ncurses-terminfo

ifeq ($(strip $(FREETZ_MC_WITH_NCURSES)),y) 
$(PKG)_DEPENDS_ON += ncurses 
endif

$(PKG)_CONFIGURE_ENV += am_cv_func_iconv=no
$(PKG)_CONFIGURE_ENV += am_cv_lib_iconv=no
$(PKG)_CONFIGURE_ENV += mc_cv_have_zipinfo=yes

$(PKG)_CONFIGURE_OPTIONS:=\
		--disable-charset \
		--disable-background \
		--disable-gcc-warnings \
		--disable-glibtest \
		--with-glib12 \
		--without-libiconv-prefix \
		--without-x \
		--with-vfs \
		--without-mcfs \
		--without-samba \
		--with-configdir=/etc \
		--without-ext2undel \
		$(if $(FREETZ_MC_SUBSHELL),--with-subshell,--without-subshell) \
		$(if $(FREETZ_MC_WITH_NCURSES),--with-screen=ncurses,--with-screen=mcslang) \
		$(if $(FREETZ_MC_INTERNAL_EDITOR),--with-edit,--without-edit)


$(PKG)_CONFIG_SUBOPTS += FREETZ_MC_INTERNAL_EDITOR
$(PKG)_CONFIG_SUBOPTS += FREETZ_MC_SUBSHELL
$(PKG)_CONFIG_SUBOPTS += FREETZ_MC_WITH_NCURSES


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MC_DIR) \
		GLIB_CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-1.2" \
		GLIB_LIBS="-lglib"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_HELP): $($(PKG)_HELP)
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

ifeq ($(strip $(FREETZ_$(PKG)_ONLINE_HELP)),y)
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_HELP)
else
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(pkg)-clean-help
endif

$(pkg)-clean-help: 
	@$(RM) $(MC_TARGET_HELP)

$(pkg)-clean:
	-$(MAKE) -C $(MC_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(MC_TARGET_BINARY)

$(PKG_FINISH)
