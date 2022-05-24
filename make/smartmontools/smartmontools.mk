$(call PKG_INIT_BIN, 7.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=@SF/smartmontools
$(PKG)_HASH:=5cd98a27e6393168bc6aaea070d9e1cd551b0f898c52f66b2ff2e5d274118cd6
### WEBSITE:=https://www.smartmontools.org/
### MANPAGE:=https://www.smartmontools.org/wiki/TocDoc
### CHANGES:=https://www.smartmontools.org/browser/trunk/smartmontools/NEWS
### CVSREPO:=https://www.smartmontools.org/timeline

$(PKG)_BINARIES := smartctl
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/,$($(PKG)_BINARIES))

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG)_CONFIGURE_OPTIONS += --without-gnupg
$(PKG)_CONFIGURE_OPTIONS += --without-selinux
$(PKG)_CONFIGURE_OPTIONS += --without-libcap-ng
$(PKG)_CONFIGURE_OPTIONS += --without-libsystemd
$(PKG)_CONFIGURE_OPTIONS += --without-nvme-devicescan


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

