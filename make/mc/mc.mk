$(call PKG_INIT_BIN, 4.6.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.ibiblio.org/pub/Linux/utils/file/managers/mc/
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION)
$(PKG)_HELP:=$($(PKG)_MAKE_DIR)/files/root/usr/share/mc/mc.hlp
$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)
$(PKG)_PKG_SITE:=http://dsmod.magenbrot.net
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mc.bin
$(PKG)_TARGET_HELP:=$($(PKG)_DEST_DIR)/usr/share/mc/mc.hlp

$(PKG)_DEPENDS_ON += ncurses glib


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	( cd $(MC_DIR); rm -f config.cache; \
		$(TARGET_CONFIGURE_OPTS) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/glib-1.2" \
		LDFLAGS="" \
		ac_cv_lib_intl_tolower=no \
		mc_cv_have_zipinfo=yes \
		am_cv_func_iconv=no \
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
		--without-gpm-mouse \
		--with-configdir=/etc \
		--without-ext2undel \
		--with-subshell \
		--with-screen=ncurses \
		--with-edit \
	);
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MC_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_HELP): $($(PKG)_HELP)
	cp $(MC_HELP) $(MC_TARGET_HELP)

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
