$(call PKG_INIT_BIN, 28a46567a8)
$(PKG)_NAME_NO_HYPHEN:=$(subst -,,$(pkg))
$(PKG)_SOURCE:=$($(PKG)_NAME_NO_HYPHEN)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=3ef0959ce163b2e9f809b36edd724fdac0333fe69fe9e1bf2d556b689b2d01fa
$(PKG)_SITE:=git@https://github.com/jstasiak/asterisk-chan-dongle.git

$(PKG)_BINARY := $($(PKG)_DIR)/chan_dongle.so
$(PKG)_BINARY_TARGET := $($(PKG)_DEST_DIR)$(ASTERISK_MODULES_DIR)/chan_dongle.so

$(PKG)_CONFIG := $($(PKG)_DIR)/etc/dongle.conf
$(PKG)_CONFIG_TARGET := $($(PKG)_DEST_DIR)$(ASTERISK_CONFIG_DIR)/dongle.conf

$(PKG)_DEPENDS_ON += asterisk
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_LIBS += -liconv
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_LOWMEMORY
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_ASTERISK_DEBUG

$(PKG)_CONFIGURE_PRE_CMDS += $(AUTORECONF)
# the only reason for calling automake is to install: config.sub, config.guess, install-sh, etc.
# the package itself is a non-automake package
$(PKG)_CONFIGURE_PRE_CMDS += automake --force-missing --add-missing 2>/dev/null;

$(PKG)_CONFIGURE_OPTIONS += --with-asterisk=$(ASTERISK_INSTALL_DIR_ABSOLUTE)/usr/include

$(PKG)_EXTRA_CFLAGS += $(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),$(ASTERISK_DEBUG_CFLAGS))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(ASTERISK_CHAN_DONGLE_DIR) \
		EXTRA_CFLAGS="$(ASTERISK_CHAN_DONGLE_EXTRA_CFLAGS)"

$($(PKG)_CONFIG): $($(PKG)_DIR)/.configured
	touch $@

$($(PKG)_BINARY_TARGET): $($(PKG)_BINARY)
	$(if $(FREETZ_PACKAGE_ASTERISK_DEBUG),$(INSTALL_FILE),$(INSTALL_BINARY_STRIP))

$($(PKG)_CONFIG_TARGET): $($(PKG)_CONFIG)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET) #$($(PKG)_CONFIG_TARGET)

$(pkg)-clean:
	-$(SUBMAKE) -C $(ASTERISK_CHAN_DONGLE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(ASTERISK_CHAN_DONGLE_BINARY_TARGET) $(ASTERISK_CHAN_DONGLE_CONFIG_TARGET)

$(PKG_FINISH)
