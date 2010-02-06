$(call PKG_INIT_BIN, 3.0.0)
$(PKG)_SOURCE:=iptraf-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://iptraf.seul.org/pub/iptraf
$(PKG)_SOURCE_MD5:=377371c28ee3c21a76f7024920649ea8

$(PKG)_DEPENDS_ON := ncurses

$(PKG)_BINARIES_ALL := iptraf rvnamed
ifeq ($(strip $(FREETZ_PACKAGE_IPTRAF_RVNAMED)),y)
$(PKG)_BINARIES := $($(PKG)_BINARIES_ALL)
else
$(PKG)_BINARIES := $(filter-out rvnamed,$($(PKG)_BINARIES_ALL))
endif
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(IPTRAF_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		INCLUDEDIR="-I../support"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE) -C $(IPTRAF_DIR)/src clean
	$(RM) $(IPTRAF_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPTRAF_BINARIES_ALL:%=$(IPTRAF_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
