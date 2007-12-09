$(call PKG_INIT_BIN, 4.6.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.ibiblio.org/pub/Linux/utils/file/managers/mc/
$(PKG)_HELP:=$($(PKG)_MAKE_DIR)/files/root/usr/share/mc/mc.hlp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mc.bin
$(PKG)_TARGET_HELP:=$($(PKG)_DEST_DIR)/usr/share/mc/mc.hlp

$(PKG)_DEPENDS_ON += glib

ifeq ($(strip $(DS_MC_WITH_NCURSES)),y) 
$(PKG)_DEPENDS_ON += ncurses 
endif

$(PKG)_DS_CONFIG_FILE:=$($(PKG)_MAKE_DIR)/.ds_config
$(PKG)_DS_CONFIG_TEMP:=$($(PKG)_MAKE_DIR)/.ds_config.temp

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"
$(PKG)_CONFIGURE_ENV += am_cv_func_iconv=no
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
		--with-subshell \
		$(if $(DS_MC_WITH_NCURSES),--with-screen=ncurses,--with-screen=mcslang) \
		$(if $(DS_MC_INTERNAL_EDITOR),--with-edit,)



$(PKG_SOURCE_DOWNLOAD)

$($(PKG)_DS_CONFIG_FILE): $(TOPDIR)/.config
	@echo "DS_MC_INTERNAL_EDITOR=$(if $(DS_MC_INTERNAL_EDITOR),y,n)" > $(MC_DS_CONFIG_TEMP)
	@echo "DS_MC_WITH_NCURSES=$(if $(DS_MC_WITH_NCURSES),y,n)" >> $(MC_DS_CONFIG_TEMP)
	@diff -q $(MC_DS_CONFIG_TEMP) $(MC_DS_CONFIG_FILE) || \
		cp $(MC_DS_CONFIG_TEMP) $(MC_DS_CONFIG_FILE)
	@rm -f $(MC_DS_CONFIG_TEMP)

$($(PKG)_DIR)/.unpacked: $(DL_DIR)/$($(PKG)_SOURCE) $($(PKG)_DS_CONFIG_FILE)
	rm -rf $(MC_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(MC_SOURCE)
	for i in $(MC_MAKE_DIR)/patches/*.patch; do \
		$(PATCH_TOOL) $(MC_DIR) $$i; \
	done
	touch $@

$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MC_DIR) \
		GLIB_CFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-1.2"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_HELP): $($(PKG)_HELP)
	mkdir -p $(dir $@)
	cp $^ $@

$(pkg):

ifeq ($(strip $(DS_$(PKG)_ONLINE_HELP)),y)
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_HELP)
else
$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $(pkg)-clean-help
endif

$(pkg)-clean-help: 
	@rm -f $(MC_TARGET_HELP)

$(pkg)-clean:
	-$(MAKE) -C $(MC_DIR) clean
	rm -f $(PACKAGES_BUILD_DIR)/$(MC_PKG_SOURCE)

$(pkg)-uninstall: 
	rm -f $(MC_TARGET_BINARY)

$(PKG_FINISH)
