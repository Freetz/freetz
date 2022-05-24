$(call PKG_INIT_BIN, 3.0.1)
$(PKG)_SOURCE:=iptraf-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=95a069af8c4d22206985f6ce69acc27cfcfef1d58ad6ab8dbb10c698642ac08a
$(PKG)_SITE:=ftp://iptraf.seul.org/pub/iptraf

$(PKG)_PATCH_POST_CMDS += $(SED) -i -r -e 's,<linux/(if_(tr|ether)[.]h)>,<netinet/\1>,g' src/*.h src/*.c;

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_BINARIES_ALL := iptraf rvnamed
ifeq ($(strip $(FREETZ_PACKAGE_IPTRAF_RVNAMED)),y)
$(PKG)_BINARIES := $($(PKG)_BINARIES_ALL)
else
$(PKG)_BINARIES := $(filter-out rvnamed,$($(PKG)_BINARIES_ALL))
endif
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IPTRAF_DIR)/src \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		INCLUDEDIR="-I../support" \
		AR="$(TARGET_AR)" \
		RANLIB="$(TARGET_RANLIB)" \
		OS=Linux \
		ARCH=$(TARGET_ARCH_ENDIANNESS_DEPENDENT)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IPTRAF_DIR)/src clean
	$(RM) $(IPTRAF_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPTRAF_BINARIES_ALL:%=$(IPTRAF_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
