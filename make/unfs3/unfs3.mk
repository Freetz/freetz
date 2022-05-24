$(call PKG_INIT_BIN, 0.9.22)
$(PKG)_SOURCE:=unfs3-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=482222cae541172c155cd5dc9c2199763a6454b0c5c0619102d8143bb19fdf1c
$(PKG)_SITE:=@SF/project/unfs3/unfs3/$($(PKG)_VERSION),https://github.com/unfs3/unfs3/releases/download/$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/unfsd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/unfsd
### WEBSITE:=https://unfs3.github.io/
### MANPAGE:=https://github.com/unfs3/unfs3/tree/master/doc
### CHANGES:=https://github.com/unfs3/unfs3/blob/master/NEWS
### CVSREPO:=https://github.com/unfs3/unfs3/commits

$(PKG)_DEPENDS_ON += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),portmap,rpcbind)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc),,libtirpc)

ifneq ($(strip $(FREETZ_TARGET_UCLIBC_SUPPORTS_rpc)),y)
$(PKG)_CFLAGS += -ltirpc -I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/tirpc
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(UNFS3_DIR) \
		CFLAGS="$(TARGET_CFLAGS) $(UNFS3_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(UNFS3_DIR) clean
	$(RM) $(UNFS3_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $($(PKG)_TARGET_BINARY)

$(PKG_FINISH)
