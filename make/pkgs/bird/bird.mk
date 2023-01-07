$(call PKG_INIT_BIN, 1.6.8)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=6c61ab5d2ef59d2559a8735b8252b5a0238013b43e5fb8a96c5d9d06e7bc00b2
$(PKG)_SITE:=https://bird.network.cz/download;ftp://bird.network.cz/pub/bird
### WEBSITE:=https://bird.network.cz/
### MANPAGE:=https://gitlab.nic.cz/labs/bird/wikis/home
### CHANGES:=https://bird.network.cz/?o_news
### CVSREPO:=https://gitlab.nic.cz/labs/bird
# v2: https://gitlab.nic.cz/labs/bird/-/wikis/transition-notes-to-bird-2

$(PKG)_STARTLEVEL=82

$(PKG)_BINARIES_ALL := bird birdc
ifeq ($(strip $(FREETZ_PACKAGE_BIRDC)),y)
$(PKG)_DEPENDS_ON += ncurses readline
$(PKG)_BINARIES := $($(PKG)_BINARIES_ALL)
else
$(PKG)_BINARIES := $(filter-out birdc,$($(PKG)_BINARIES_ALL))
endif
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIRD_DEBUG
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BIRDC
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIRDC),--enable-client,--disable-client)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BIRD_DEBUG),--enable-debug,--disable-debug)
$(PKG)_CONFIGURE_OPTIONS += --disable-memcheck
#$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(BIRD_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(BIRD_DIR) clean
	$(RM) $(BIRD_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BIRD_BINARIES_ALL:%=$(BIRD_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
