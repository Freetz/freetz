$(call PKG_INIT_BIN,1.4.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://www.very-clever.com/download/nongnu/davfs2
$(PKG)_MOUNT_BINARY:=$($(PKG)_DIR)/src/mount.davfs
$(PKG)_MOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/mount.davfs
$(PKG)_UMOUNT_BINARY:=$($(PKG)_DIR)/src/umount.davfs
$(PKG)_UMOUNT_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/umount.davfs
$(PKG)_SOURCE_MD5:=d9ce95298fe57d6ff8b7a040064ab0fd

$(PKG)_DEPENDS_ON := neon
$(PKG)_LIBS := -lneon

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_VERSION_0_9_28)),y)
$(PKG)_DEPENDS_ON += iconv
$(PKG)_LIBS += -liconv
endif

$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DAVFS2_WITH_SSL
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_DAVFS2_WITH_ZLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_MOUNT_BINARY) $($(PKG)_UMOUNT_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(DAVFS2_DIR) \
		LIBS="$(DAVFS2_LIBS)"

$($(PKG)_MOUNT_TARGET_BINARY): $($(PKG)_MOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_UMOUNT_TARGET_BINARY): $($(PKG)_UMOUNT_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_MOUNT_TARGET_BINARY) $($(PKG)_UMOUNT_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(DAVFS2_DIR) clean

$(pkg)-uninstall:
	$(RM) $(DAVFS2_MOUNT_TARGET_BINARY)
	$(RM) $(DAVFS2_UMOUNT_TARGET_BINARY)

$(PKG_FINISH)
