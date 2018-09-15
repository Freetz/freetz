$(call PKG_INIT_BIN, 0.0.20180809)
$(PKG)_SOURCE:=WireGuard-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=2d5554aae3c87a5ab0250528c7a05476
$(PKG)_SITE:=https://git.zx2c4.com/WireGuard/snapshot

$(PKG)_BINARIES            := wg
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/src/tools/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_MODULES            := wireguard.ko
$(PKG)_MODULES_BUILD_DIR  := $($(PKG)_MODULES:%=$($(PKG)_DIR)/src/%)
$(PKG)_MODULES_TARGET_DIR := $($(PKG)_MODULES:%=$(KERNEL_MODULES_DIR)/drivers/net/wireguard/%)

$(PKG)_DEPENDS_ON += kernel libmnl

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WIREGUARD_DIR)/src tools \
		CC="$(TARGET_CC)"

$($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WIREGUARD_DIR)/src module \
		SUBDIRS="$(FREETZ_BASE_DIR)/$(WIREGUARD_DIR)/src" \
		KERNELDIR="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
		ARCH="$(TARGET_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/src/tools/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $(KERNEL_MODULES_DIR)/drivers/net/wireguard/%: $($(PKG)_DIR)/src/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WIREGUARD_DIR)/src clean \
		SUBDIRS="$(FREETZ_BASE_DIR)/$(WIREGUARD_DIR)/src" \
		KERNELDIR="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
		ARCH="$(TARGET_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)"

$(pkg)-uninstall:
	$(RM) \
		$(WIREGUARD_BINARIES_TARGET_DIR) \
		$(WIREGUARD_MODULES_TARGET_DIR)

$(PKG_FINISH)
