$(call PKG_INIT_BIN, 0.2.15)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/umurmur/umurmur

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_PATCH_POST_CMDS += $(call POLARSSL_HARDCODE_VERSION,13,configure.ac src/crypt.h src/ssl.h src/ssli_polarssl.c)
$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_POLARSSL

$(PKG)_DEPENDS_ON += libconfig protobuf-c
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=openssl
endif
ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_POLARSSL)),y)
$(PKG)_DEPENDS_ON += polarssl13
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=polarssl
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UMURMUR_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UMURMUR_DIR) clean
	$(RM) $(UMURMUR_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UMURMUR_TARGET_BINARY)

$(PKG_FINISH)
