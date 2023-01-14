$(call TOOLS_INIT, v2023.01)
$(PKG)_SOURCE:=uboot-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=5b5c697d1cd4a9099ba51061949ab1a39e11704f7a109c6bd69a1194c2abb7c8
$(PKG)_SITE:=git@https://github.com/u-boot/u-boot.git
### CHANGES:=https://github.com/u-boot/u-boot/tags
### CVSREPO:=https://github.com/u-boot/u-boot

$(PKG)_INSTALL_DIR := $(TOOLS_DIR)/fit

$(PKG)_BINARIES            := dumpimage fdtgrep mkimage
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/tools/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_INSTALL_DIR)/%)

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_UBOOT_STATIC),static_openssl)
$(PKG)_REBUILD_SUBOPTS += FREETZ_UBOOT_STATIC


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBMAKE) -C $(UBOOT_HOST_DIR) tools-only_defconfig
	touch $@

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(UBOOT_HOST_DIR) tools-only

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_INSTALL_DIR)/%: $($(PKG)_DIR)/tools/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(UBOOT_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(UBOOT_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(UBOOT_HOST_INSTALL_DIR)/dumpimage \
		$(UBOOT_HOST_INSTALL_DIR)/fdtgrep \
		$(UBOOT_HOST_INSTALL_DIR)/mkimage

$(TOOLS_FINISH)
