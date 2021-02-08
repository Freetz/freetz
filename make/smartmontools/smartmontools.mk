$(call PKG_INIT_BIN, 7.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/smartmontools
$(PKG)_SOURCE_MD5:=e8d134c69ae4959a05cb56b31172ffb1

$(PKG)_BINARIES := smartctl
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/,$($(PKG)_BINARIES))

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONFIGURE_OPTIONS += --without-nvme-devicescan
ifeq ($(strip $(FREETZ_TARGET_GCC_4_MAX)),y)
$(PKG)_CONFIGURE_OPTIONS += CFLAGS="$(TARGET_CFLAGS) -fno-stack-protector" 
$(PKG)_CONFIGURE_OPTIONS += CXXFLAGS="$(TARGET_CFLAGS) -fno-stack-protector"
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SMARTMONTOOLS_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SMARTMONTOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SMARTMONTOOLS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
