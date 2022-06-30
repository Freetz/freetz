$(call PKG_INIT_BIN, 1.0.20220627)
$(PKG)_SOURCE:=wireguard-linux-compat-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=362d412693c8fe82de00283435818d5c5def7f15e2433a07a9fe99d0518f63c0
$(PKG)_SITE:=https://git.zx2c4.com/wireguard-linux-compat/snapshot
### CHANGES:=https://git.zx2c4.com/wireguard-linux-compat/log/
### CVSREPO:=https://git.zx2c4.com/wireguard-linux-compat/

$(PKG)_MODULE:=$($(PKG)_DIR)/src/wireguard.ko
$(PKG)_TARGET_MODULE:=$(KERNEL_MODULES_DIR)/drivers/net/wireguard/wireguard.ko

$(PKG)_DEPENDS_ON += kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_AVM_SOURCE_ID
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_WIREGUARD_LINUX_COMPAT_skb_put_data),skb_put_data)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_MODULE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WIREGUARD_LINUX_COMPAT_DIR)/src \
		SUBDIRS="$(FREETZ_BASE_DIR)/$(WIREGUARD_LINUX_COMPAT_DIR)/src" \
		KERNELDIR="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
		ARCH="$(KERNEL_ARCH)" \
		CROSS_COMPILE="$(KERNEL_CROSS)"

$($(PKG)_TARGET_MODULE): $($(PKG)_MODULE)
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_MODULE)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WIREGUARD_LINUX_COMPAT_DIR)/src clean

$(pkg)-uninstall:
	$(RM)  $(WIREGUARD_LINUX_COMPAT_TARGET_MODULE)

$(PKG_FINISH)
