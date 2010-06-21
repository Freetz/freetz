$(call PKG_INIT_BIN, 0.9.10)
$(PKG)_SOURCE:=mcabber-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=887415d16c32af58eab2ec2d9bb17fa6
$(PKG)_SITE:=http://mirror.mcabber.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/mcabber
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mcabber

$(PKG)_DEPENDS_ON := glib2 ncurses

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MCABBER_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_MCABBER_WITH_SSL

ifeq ($(strip $(FREETZ_PACKAGE_MCABBER_WITH_SSL)),y)
$(PKG)_DEPENDS_ON += openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_MCABBER_STATIC)),y)
$(PKG)_LDFLAGS := -static
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_MCABBER_WITH_SSL),--with-openssl,--without-ssl)
$(PKG)_CONFIGURE_OPTIONS += --disable-gpgme

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MCABBER_DIR) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="$(MCABBER_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(MCABBER_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MCABBER_TARGET_BINARY)

$(PKG_FINISH)
