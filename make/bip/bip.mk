$(call PKG_INIT_BIN, 0.9.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f643b39b7af2a0d5fe7c45c57ffe3e6710be33278455eab8aeefe5b2842764ea
$(PKG)_SITE:=https://projects.duckcorp.org/attachments/download/103
### WEBSITE:=https://projects.duckcorp.org/projects/bip
### MANPAGE:=https://bip.milkypond.org/projects/bip/wiki
### CHANGES:=https://projects.duckcorp.org/projects/bip/news
### CVSREPO:=https://projects.duckcorp.org/projects/bip/repository

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_BINARIES:=bip $(if $(FREETZ_PACKAGE_BIP_BIPMKPW),bipmkpw)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,LDFLAGS|LIBS)

ifeq ($(strip $(FREETZ_PACKAGE_BIP_WITH_SSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
endif

ifeq ($(strip $(FREETZ_PACKAGE_BIP_STATIC)),y)
$(PKG)_LDFLAGS := -static
ifeq ($(strip $(FREETZ_PACKAGE_BIP_WITH_SSL)),y)
$(PKG)_STATIC_LIBS += $(OPENSSL_LIBCRYPTO_EXTRA_LIBS)
endif
endif

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIP_WITH_SSL),--with-openssl,--without-openssl)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIP_WITH_OIDENTD),--enable-oidentd)
$(PKG)_CONFIGURE_OPTIONS += --disable-pie

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIP_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIP_WITH_SSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIP_WITH_OIDENTD

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BIP_DIR) \
		EXTRA_LDFLAGS="$(BIP_LDFLAGS)" \
		EXTRA_LIBS="$(BIP_STATIC_LIBS)"

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BIP_DIR) clean
	$(RM) $(BIP_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BIP_BINARIES_TARGET_DIR)

$(PKG_FINISH)
