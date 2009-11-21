$(call PKG_INIT_BIN, 0.9.9)
$(PKG)_SOURCE:=mcabber-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://mirror.mcabber.com/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/mcabber
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mcabber
$(PKG)_SOURCE_MD5:=189fb9d23f5a8412bc660884528475ea

$(PKG)_DEPENDS_ON := glib2 ncurses ncurses-panel

$(PKG)_LIBS := -lpanel -lncurses -lintl -lm -lglib-2.0

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_MCABBER_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_MCABBER_WITH_FIFO
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_MCABBER_WITH_SSL

ifeq ($(strip $(FREETZ_PACKAGE_MCABBER_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
$(PKG)_LIBS += -lssl -lcrypto -ldl
endif

ifeq ($(strip $(FREETZ_PACKAGE_MCABBER_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MCABBER_WITH_SSL),--with-openssl, --without-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MCABBER_WITH_FIFO),--enable-fifo,)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)
		
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MCABBER_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(MCABBER_LDFLAGS)" \
		LIBS="$(MCABBER_LIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MCABBER_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MCABBER_TARGET_BINARY)

$(PKG_FINISH)
