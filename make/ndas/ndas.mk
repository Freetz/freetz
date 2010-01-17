$(call PKG_INIT_BIN, 1.1-22)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).mipsel.tar.bz2
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/ndasadmin
$(PKG)_MOD_BINARY:=$($(PKG)_DIR)/ndas_block.ko
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ndasadmin
$(PKG)_MOD_TARGET_DIR:=$(KERNEL_MODULES_DIR)/lib/modules/$(KERNEL_VERSION)-$(KERNEL_LAYOUT)/kernel/fs/ndas
$(PKG)_MOD_TARGET_BINARY:=$($(PKG)_MOD_TARGET_DIR)/ndas_block.ko
$(PKG)_SOURCE_MD5:=f6b5d28b638ac074f54d404e4c136d5e

$(PKG)_DEPENDS_ON := kernel

$(PKG)_MODULES:=ndas_block.ko ndas_core.ko ndas_sal.ko

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

$($(PKG)_MOD_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(KERNEL_MAKE_PATH):$(PATH)" \
		$(MAKE1) -C $(NDAS_DIR) \
		$(NDAS_OPTIONS) \
		ARCH="$(KERNEL_ARCH)" \
		CC="$(KERNEL_CROSS)gcc" \
		LD="$(KERNEL_CROSS)ld" \
		AR="$(KERNEL_CROSS)ar" \
		ndas-kernel

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(NDAS_DIR) \
		$(NDAS_OPTIONS) ndas-admin

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MOD_TARGET_BINARY): $($(PKG)_MOD_BINARY)
	mkdir -p $(dir $@)
	for i in $(NDAS_MODULES); do \
		cp $(NDAS_DIR)/$$i $(NDAS_MOD_TARGET_DIR); \
	done

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_MOD_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(NDAS_DIR) \
		$(NDAS_OPTIONS) \
		clean
	$(RM) $(NDAS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NDAS_TARGET_BINARY)

$(PKG_FINISH)
