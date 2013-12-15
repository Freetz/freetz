$(call PKG_INIT_BIN, 1.1-22)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).mipsel.tar.bz2
$(PKG)_SOURCE_MD5:=f6b5d28b638ac074f54d404e4c136d5e
$(PKG)_SITE:=http://freetz.magenbrot.net

$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_DIR)/ndasadmin
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_DEST_DIR)/usr/bin/ndasadmin

$(PKG)_MODULES:=ndas_block.ko ndas_core.ko ndas_sal.ko
$(PKG)_MODULES_BUILD_DIR:=$($(PKG)_MODULES:%=$($(PKG)_DIR)/%)
$(PKG)_MODULES_TARGET_DIR:=$($(PKG)_MODULES:%=$(KERNEL_MODULES_DIR)/fs/ndas/%)

$(PKG)_DEPENDS_ON := kernel

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

NDAS_OPTIONS:= \
	NDAS_KERNEL_PATH="$(FREETZ_BASE_DIR)/$(KERNEL_SOURCE_DIR)" \
	NDAS_KERNEL_VERSION=$(strip $(FREETZ_KERNEL_VERSION)) \
	NDAS_KERNEL_ARCH=mipsel \
	NDAS_CROSS_COMPILE=mipsel-unknown-linux-gnu- \
	NDAS_CROSS_COMPILE_UM=mipsel-linux-uclibc- \
	NDAS_EXTRA_CFLAGS="-mlong-calls" \
	I_agree_the_XIMETA_EULA=true

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NDAS_DIR) \
		$(NDAS_OPTIONS) ndas-admin

$($(PKG)_MODULES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(NDAS_DIR) \
		$(NDAS_OPTIONS) \
		ARCH="$(KERNEL_ARCH)" \
		CC="$(KERNEL_CROSS)gcc" \
		LD="$(KERNEL_CROSS)ld" \
		AR="$(KERNEL_CROSS)ar" \
		ndas-kernel

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_TARGET_DIR): $(KERNEL_MODULES_DIR)/fs/ndas/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_MODULES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NDAS_DIR) $(NDAS_OPTIONS) clean

$(pkg)-uninstall:
	$(RM) $(NDAS_BINARY_TARGET_DIR) $(NDAS_MODULES_TARGET_DIR)

$(PKG_FINISH)
