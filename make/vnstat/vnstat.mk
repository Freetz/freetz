$(call PKG_INIT_BIN, 1.15)
$(PKG)_SOURCE:=vnstat-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=351051ef3005e3ca99123eec07ac0a7d
$(PKG)_SITE:=http://humdi.net/vnstat

$(PKG)_BINARIES_ALL := vnstat vnstatd vnstati
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_VNSTAT_DAEMON),,vnstatd) $(if $(FREETZ_PACKAGE_VNSTAT_IMAGE),,vnstati),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

ifeq ($(strip $(FREETZ_PACKAGE_VNSTAT_IMAGE)),y)
$(PKG)_DEPENDS_ON += libgd
$(PKG)_MAKE_TARGET := all
# using cached value of "ac_cv_lib_gd_gdImageLine" might break the build of vnstati (with image support) 
# for a (later) build of the required libgd would not be honored after a prior run of configure (without libgd)  
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e  '/if.*ac_cv_lib_gd_gdImageLine.*false/ s,ac_cv_lib_gd_gdImageLine,lib_gd_gdImageLine,' ./configure;
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(VNSTAT_MAKE_TARGET) -C $(VNSTAT_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(VNSTAT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(VNSTAT_BINARIES_ALL:%=$(VNSTAT_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
