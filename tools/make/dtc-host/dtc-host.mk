$(call TOOLS_INIT, 1.6.1)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=65cec529893659a49a89740bb362f507a3b94fc8cd791e76a8d6a2b6f3203473
$(PKG)_SITE:=@KERNEL/software/utils/dtc

$(PKG)_INSTALL_DIR := $(TOOLS_DIR)/fit

$(PKG)_BINARIES            := dtc fdtdump fdtget fdtput fitdump
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_INSTALL_DIR)/%)


# libdtc-host uses same
$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -C $(DTC_HOST_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_INSTALL_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(DTC_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(DTC_HOST_INSTALL_DIR)/dtc \
		$(DTC_HOST_INSTALL_DIR)/fdtget \
		$(DTC_HOST_INSTALL_DIR)/fdtdump \
		$(DTC_HOST_INSTALL_DIR)/fdtput \
		$(DTC_HOST_INSTALL_DIR)/mkimage \
		$(DTC_HOST_INSTALL_DIR)/fitdump

$(TOOLS_FINISH)
