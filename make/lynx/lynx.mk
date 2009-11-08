$(call PKG_INIT_BIN, 2.8.5)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://lynx.isc.org/lynx$($(PKG)_VERSION)
$(PKG)_DIR:=$(SOURCE_DIR)/$(pkg)2-8-5
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_CFG:=$($(PKG)_DIR)/lynx.cfg
$(PKG)_TARGET_CFG:=$($(PKG)_TARGET_DIR)/root/etc/lynx.cfg
$(PKG)_TARGET_BINARY:=$(LYNX_TARGET_DIR)/root/usr/bin/lynx
$(PKG)_SOURCE_MD5:=d1e5134e5d175f913c16cb6768bc30eb 

$(PKG)_CONFIGURE_OPTIONS=\
	--enable-warnings \
	--with-screen=ncurses \
	--enable-nested-tables --enable-read-eta \
	--enable-charset-choice \
	--disable-alt-bindings \
	--disable-bibp-urls \
	--disable-config-info \
	--disable-dired \
	--disable-finger \
	--disable-gopher \
	--disable-news \
	--disable-nls \
	--disable-prettysrc \
	--disable-source-cache \
	--disable-trace \

$(PKG)_DEPENDS_ON := ncurses


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	( cd $(LYNX_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_ENV) \
		CFLAGS="$(TARGET_CFLAGS)" \
		CPPFLAGS="-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include" \
		LDFLAGS="-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib" \
		ac_cv_prog_CC="$(GNU_TARGET_NAME)-gcc" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--sbindir=/usr/sbin \
		--libexecdir=/usr/lib \
		--datadir=/usr/share \
		--sysconfdir=/etc \
		--localstatedir=/var \
		--libdir=/etc \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--mandir=/usr/share/man \
		$(DISABLE_LARGEFILE) \
		$(DISABLE_NLS) \
		$(LYNX_CONFIGURE_OPTIONS) \
	);
	touch $@

$($(PKG)_BINARY) $($(PKG)_CFG): $($(PKG)_DIR)/.configured
		$(SUBMAKE) -C $(LYNX_DIR) \
		LD="$(TARGET_LD)"
	touch $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_CFG): $($(PKG)_CFG)
	mkdir -p $(dir $@) 
	cp $(LYNX_CFG) $(LYNX_TARGET_CFG)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_CFG)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LYNX_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(LYNX_TARGET_BINARY)
	$(RM) $(LYNX_TARGET_CFG)

$(PKG_FINISH)

