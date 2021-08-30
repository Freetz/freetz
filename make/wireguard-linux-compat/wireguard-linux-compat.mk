$(call PKG_INIT_BIN, 1.0.20210606)
$(PKG)_SOURCE:=wireguard-linux-compat-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=3f5d990006e6eabfd692d925ec314fff2c5ee7dcdb869a6510d579acfdd84ec0
$(PKG)_SITE:=https://git.zx2c4.com/wireguard-linux-compat/snapshot
### CHANGES:=https://git.zx2c4.com/wireguard-linux-compat/log/
### CVSREPO:=https://git.zx2c4.com/wireguard-linux-compat/

$(PKG)_REBUILD_SUBOPTS += FREETZ_AVM_VERSION_07_2X_MIN
$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION_4_4_60
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_KERNEL_VERSION_4_4_60),$(if $(FREETZ_AVM_VERSION_07_2X_MIN),07_2X_MIN))

$(PKG)_MODULE:=$($(PKG)_DIR)/src/wireguard.ko
$(PKG)_TARGET_MODULE:=$(KERNEL_MODULES_DIR)/drivers/net/wireguard/wireguard.ko

$(PKG)_DEPENDS_ON += kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

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
