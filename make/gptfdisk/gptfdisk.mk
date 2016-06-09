$(call PKG_INIT_BIN, 1.0.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=d7f3d306b083123bcc6f5941efade586
$(PKG)_SITE:=http://pkgs.fedoraproject.org/lookaside/pkgs/gdisk/$(pkg)-$($(PKG)_VERSION).tar.gz/md5/$($(PKG)_SOURCE_MD5)

# log2/log are provided by libm in uClibc
$(PKG)_PATCH_POST_CMDS += $(SED) -r -i -e 's,(-luuid),\1 -lm,g' Makefile;

$(PKG)_CATEGORY:=Unstable

$(PKG)_BINARY:=$($(PKG)_DIR)/gdisk
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/gdisk

$(PKG)_DEPENDS_ON += e2fsprogs
$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GPTFDISK_DIR) gdisk \
		CXX="$(TARGET_CXX)" \
		CXXFLAGS="$(TARGET_CFLAGS) -D_BSD_SOURCE"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GPTFDISK_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GPTFDISK_TARGET_BINARY)

$(PKG_FINISH)
