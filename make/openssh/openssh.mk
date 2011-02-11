$(call PKG_INIT_BIN, 5.1p1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable/
$(PKG)_BINARY:=$($(PKG)_DIR)/sftp-server
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/lib/sftp-server

$(PKG)_DEPENDS_ON := openssl zlib

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_OPENSSH_STATIC

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENSSH_STATIC),--disable-shared,--enable-shared)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENSSH_STATIC),--enable-static,--disable-static)
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-etc-default-login
$(PKG)_CONFIGURE_OPTIONS += --disable-lastlog
$(PKG)_CONFIGURE_OPTIONS += --disable-utmp
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmp
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmpx
$(PKG)_CONFIGURE_OPTIONS += --without-bsd-auth
$(PKG)_CONFIGURE_OPTIONS += --without-kerberos5

ifeq ($(strip $(FREETZ_PACKAGE_OPENSSH_STATIC)),y)
OPENSSH_LDFLAGS := "-static -all-static -L. -Lopenbsd-compat/"
else
OPENSSH_LDFLAGS := "-L. -Lopenbsd-compat/"
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured 
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(OPENSSH_DIR) sftp-server \
		LDFLAGS=$(OPENSSH_LDFLAGS)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(OPENSSH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENSSH_TARGET_BINARY)

$(PKG_FINISH)
