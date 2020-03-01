$(call PKG_INIT_BIN, 0.0.20200215)
$(PKG)_SOURCE:=wireguard-linux-compat-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=0def6f3608ec06f6dfc454aa5281a7c38b06ff27096cb341448d20602da4e923
$(PKG)_SITE:=https://git.zx2c4.com/wireguard-linux-compat/snapshot

$(PKG)_MODULE:=$($(PKG)_DIR)/src/wireguard.ko
$(PKG)_TARGET_MODULE:=$(KERNEL_MODULES_DIR)/drivers/net/wireguard/wireguard.ko

$(PKG)_DEPENDS_ON += kernel 

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_MODULE): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WIREGUARD_LINUX_COMPAT_DIR)/src  \
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
	$(RM)  $(WIREGUARD_TARGET_MODULE) 

$(PKG_FINISH)
