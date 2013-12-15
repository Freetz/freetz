ifeq ($(strip $(FREETZ_PACKAGE_NDAS_OPEN_SOURCE_AVAILABLE)),y)
$(call PKG_INIT_BIN, 1aaf88acd0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/iocellnetworks/ndas4linux.git
$(PKG)_CONDITIONAL_PATCHES+=open_source
$(PKG)_PRELIMINARY_BUILD_DIR:=$($(PKG)_DIR)/$(KERNEL_VERSION)
$(PKG)_BUILD_DIR:=$($(PKG)_PRELIMINARY_BUILD_DIR)/build_freetz/ndas-$(KERNEL_VERSION)
else
$(call PKG_INIT_BIN, 1.1-22)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).mipsel.tar.bz2
$(PKG)_SOURCE_MD5:=f6b5d28b638ac074f54d404e4c136d5e
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_CONDITIONAL_PATCHES+=closed_source
$(PKG)_BUILD_DIR:=$($(PKG)_DIR)
endif

$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_BUILD_DIR)/ndasadmin
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_DEST_DIR)/usr/bin/ndasadmin

$(PKG)_MODULES:=ndas_block.ko ndas_core.ko ndas_sal.ko
$(PKG)_MODULES_BUILD_DIR:=$($(PKG)_MODULES:%=$($(PKG)_BUILD_DIR)/%)
$(PKG)_MODULES_TARGET_DIR:=$($(PKG)_MODULES:%=$(KERNEL_MODULES_DIR)/fs/ndas/%)

$(PKG)_DEPENDS_ON := kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

#TODO: add support for 2.6.28 => NDAS_VER_BUILD:=32/28
NDAS_OPTIONS:= \
	NDAS_KERNEL_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
	NDAS_KERNEL_VERSION=$(strip $(FREETZ_KERNEL_VERSION)) \
	NDAS_KERNEL_ARCH=$(call qstrip,$(FREETZ_TARGET_ARCH)) \
	NDAS_CROSS_COMPILE=$(TARGET_CROSS) \
	NDAS_CROSS_COMPILE_UM=$(TARGET_CROSS) \
	NDAS_EXTRA_CFLAGS="-mlong-calls -Wno-unused-but-set-variable -Wno-unused-function" \
	I_agree_the_XIMETA_EULA=true

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.exported: $($(PKG)_DIR)/.configured
ifeq ($(strip $(FREETZ_PACKAGE_NDAS_OPEN_SOURCE_AVAILABLE)),y)
	touch $(NDAS_PRELIMINARY_BUILD_DIR)/arch/vendor/freetz.mk
	$(SUBMAKE) -C $(NDAS_PRELIMINARY_BUILD_DIR) \
		$(NDAS_OPTIONS) \
		XPLAT_OBFUSCATE=y \
		nxp-os=linux \
		nxp-cpu=$(call qstrip,$(FREETZ_TARGET_ARCH)) \
		nxp-vendor=freetz \
		nxpo-asy=y \
		nxpo-automated=y \
		nxpo-bpc=y \
		nxpo-embedded=n \
		nxpo-hix=y \
		nxpo-persist=y \
		nxpo-pnp=y \
		nxpo-raid=n \
		nxpo-release=y \
		nxpo-sio=y \
		nxpo-uni=y \
		all
endif
	touch $@

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured | $($(PKG)_DIR)/.exported
	$(SUBMAKE) -C $(NDAS_BUILD_DIR) \
		$(NDAS_OPTIONS) \
		ndas-admin

$($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured | $($(PKG)_DIR)/.exported
	$(SUBMAKE1) -C $(NDAS_BUILD_DIR) \
		$(NDAS_OPTIONS) \
		ARCH="$(KERNEL_ARCH)" \
		CC="$(KERNEL_CROSS)gcc" \
		LD="$(KERNEL_CROSS)ld" \
		AR="$(KERNEL_CROSS)ar" \
		ndas-kernel

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $(KERNEL_MODULES_DIR)/fs/ndas/%: $($(PKG)_BUILD_DIR)/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NDAS_BUILD_DIR) $(NDAS_OPTIONS) clean
	$(RM) $(NDAS_DIR)/.exported

$(pkg)-uninstall:
	$(RM) $(NDAS_BINARY_TARGET_DIR) $(NDAS_MODULES_TARGET_DIR)

$(PKG_FINISH)
