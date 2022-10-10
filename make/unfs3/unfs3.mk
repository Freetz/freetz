$(call PKG_INIT_BIN, 0.9.23)
$(PKG)_SOURCE:=unfs3-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=5fc913aa0a1f3580fa691a32be835b6b5aed9d5abe0af3fd623d13e55a69f6c2
$(PKG)_SITE:=@SF/project/unfs3/unfs3/$($(PKG)_VERSION),https://github.com/unfs3/unfs3/releases/download/unfs3-$($(PKG)_VERSION)
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
