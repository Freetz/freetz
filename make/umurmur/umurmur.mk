$(call PKG_INIT_BIN, 0.2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c31fd72c0ac563cf75961ae4e49909d7
$(PKG)_SITE:=http://$(pkg).googlecode.com/files

$(PKG)_BINARY:=$($(PKG)_DIR)/src/$(pkg)d
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/$(pkg)d

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_UMURMUR_USE_POLARSSL

$(PKG)_DEPENDS_ON := libconfig

ifeq ($(strip $(FREETZ_PACKAGE_UMURMUR_USE_POLARSSL)),y)
$(PKG)_DEPENDS_ON += polarssl
$(PKG)_EXTRA_CFLAGS := -DUSE_POLARSSL
$(PKG)_EXTRA_LDFLAGS := -lpolarssl
else
$(PKG)_DEPENDS_ON += openssl
$(PKG)_EXTRA_LDFLAGS := -lssl -lcrypto
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UMURMUR_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(UMURMUR_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(UMURMUR_EXTRA_LDFLAGS)" \
		AR="$(TARGET_AR)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UMURMUR_DIR)/src clean
	$(RM) $(UMURMUR_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UMURMUR_TARGET_BINARY)

$(PKG_FINISH)
