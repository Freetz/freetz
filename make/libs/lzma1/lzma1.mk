$(call PKG_INIT_LIB, 465)
$(PKG)_SOURCE:=lzma$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=29d5ffd03a5a3e51aef6a74e9eafb759
$(PKG)_SITE:=@SF/sevenzip
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/lzma$($(PKG)_VERSION)

$(PKG)_DEPENDS_ON += zlib

$(PKG)_BINARY:=$($(PKG)_DIR)/C/LzmaLib/liblzma.a
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma1.a

define $(PKG)_CUSTOM_UNPACK
mkdir -p $($(PKG)_DIR); $(call UNPACK_TARBALL,$(1),$($(PKG)_DIR))
endef

ifneq ($(strip $(DL_DIR)/$(LZMA1_SOURCE)),$(strip $(DL_DIR)/$(LZMA1_HOST_SOURCE)))
$(PKG_SOURCE_DOWNLOAD)
endif
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LZMA1_DIR)/C/LzmaLib -f makefile.gcc \
		CC=$(TARGET_CC) \
		CPPFLAGS="-I ../ -D_GNU_SOURCE" \
		CFLAGS="-std=c99 -W -Wall -Wno-unused-but-set-variable -Wno-unused-parameter $(TARGET_CFLAGS)" \
		AR=$(TARGET_AR) RANLIB=$(TARGET_RANLIB)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	cp -a $(LZMA1_DIR)/C/LZMA_ZLibCompat.h $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/
	$(INSTALL_FILE)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled:

$(pkg)-clean:
	-$(SUBMAKE) -C $(LZMA1_DIR)/C/LzmaLib -f makefile.gcc clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/liblzma1.a \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/LZMA_ZLibCompat.h

$(PKG_FINISH)
