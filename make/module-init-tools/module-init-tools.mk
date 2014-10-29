$(call PKG_INIT_BIN,3.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=8b2257ce9abef74c4a44d825d23140f3
$(PKG)_SITE:=@KERNEL/linux/utils/kernel/$(pkg)

$(PKG)_BINARIES_ALL := depmod insmod lsmod modindex modinfo modprobe rmmod
$(PKG)_BINARIES := $(strip $(foreach binary,$($(PKG)_BINARIES_ALL),$(if $(FREETZ_PACKAGE_$(PKG)_$(binary)),$(binary))))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/build/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MODULE_INIT_TOOLS_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/build/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MODULE_INIT_TOOLS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MODULE_INIT_TOOLS_BINARIES_ALL:%=$(MODULE_INIT_TOOLS_DEST_DIR)/usr/sbin/%)

$(PKG_FINISH)
