$(call PKG_INIT_BIN, 0.9.7)
$(PKG)_SOURCE:=mcabber-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.lilotux.net/~mikael/mcabber/files
$(PKG)_BINARY:=$($(PKG)_DIR)/src/mcabber
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mcabber

$(PKG)_DEPENDS_ON := glib2 ncurses ncurses-panel

MYLIBS:=-lpanel -lncurses -lintl -liconv -lm -lglib-2.0

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_MCABBER_STATIC
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_MCABBER_WITH_FIFO
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_MCABBER_WITH_SSL

ifeq ($(strip $(FREETZ_PACKAGE_MCABBER_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
MYLIBS+=-lssl -lcrypto -ldl
endif

$(PKG)_CONFIGURE_ENV += PKG_CONFIG_PATH="$(TARGET_MAKE_PATH)/../usr/lib/pkgconfig"

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MCABBER_WITH_SSL),--with-openssl, --without-ssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MCABBER_WITH_FIFO),--enable-fifo,)

MYLDFLAGS:= ""
ifeq ($(strip $(FREETZ_PACKAGE_MCABBER_STATIC)),y)
MYLDFLAGS:= "-static"
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)
		
$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(MCABBER_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(MYLDFLAGS)" \
		LIBS="$(MYLIBS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): 

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(MCABBER_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MCABBER_TARGET_BINARY)

$(PKG_FINISH)
