$(call PKG_INIT_BIN, 2.8.7)
$(PKG)_SOURCE:=$(pkg)$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://lynx.isc.org/lynx$($(PKG)_VERSION)
$(PKG)_SOURCE_MD5:=493af4c77ef6761e3f0157cd1be033a0
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)2-8-7
$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_CFG:=$($(PKG)_DIR)/lynx.cfg
$(PKG)_TARGET_CFG:=$($(PKG)_TARGET_DIR)/root/etc/lynx.cfg
$(PKG)_TARGET_BINARY:=$(LYNX_TARGET_DIR)/root/usr/bin/lynx

$(PKG)_CONFIGURE_OPTIONS := \
	--enable-warnings \
	--with-screen=ncurses \
	--enable-nested-tables \
	--enable-read-eta \
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
$(PKG_CONFIGURED_CONFIGURE)

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

