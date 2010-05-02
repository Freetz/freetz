$(call PKG_INIT_BIN, 1.2)
$(PKG)_SOURCE:=tmux-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=748fbe7bb5f86812e19bd6005ff21a5a
$(PKG)_SITE:=@SF/tmux
$(PKG)_BINARY:=$($(PKG)_DIR)/tmux
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/tmux

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_TMUX_STATIC

$(PKG)_DEPENDS_ON := ncurses libevent

$(PKG)_CFLAGS := -DLLONG_MIN=LONG_MIN -DLLONG_MAX=LONG_MAX -DIOV_MAX=1024 -DBUILD="\\\"$($(PKG)_VERSION)\\\""

ifeq ($(strip $(FREETZ_PACKAGE_TMUX_STATIC)),y)
$(PKG)_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TMUX_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(TMUX_CFLAGS)" \
		LDFLAGS="$(TMUX_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TMUX_DIR) clean
	$(RM) $(TMUX_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(TMUX_TARGET_BINARY)

$(PKG_FINISH)
