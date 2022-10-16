$(call PKG_INIT_BIN, 1.6.1)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
$(PKG)_SITE:=@KERNEL/software/utils/dtc
### WEBSITE:=https://git.kernel.org/pub/scm/utils/dtc/dtc.git
### CHANGES:=https://git.kernel.org/pub/scm/utils/dtc/dtc.git/log/
### CVSREPO:=https://git.kernel.org/pub/scm/utils/dtc/dtc.git/refs/

$(PKG)_BINARIES            := fdtdump fdtget fdtput fitdump
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_DTC_fdtdump) ,,usr/bin/fdtdump)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_DTC_fdtget)  ,,usr/bin/fdtget)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_DTC_fdtput)  ,,usr/bin/fdtput)
$(PKG)_EXCLUDED += $(if $(FREETZ_PACKAGE_DTC_fitdump) ,,usr/bin/fitdump)


# libdtc-host, dtc-host and fitdump using the same source
ifneq ($($(PKG)_SOURCE),$(DTC_HOST_SOURCE))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(DTC_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -O0" \
		LDFLAGS="$(TARGET_LDFLAGS)" \
		$(DTC_BINARIES)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(DTC_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DTC_BINARIES_TARGET_DIR)

$(PKG_FINISH)
