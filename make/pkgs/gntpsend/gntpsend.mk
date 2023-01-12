$(call PKG_INIT_BIN, 8241d46903)
$(PKG)_SOURCE := $(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=a8e81da289b569007bd8e7b3972310f07badd1a0c83b94156ebc330d793651b9
$(PKG)_SITE := git@https://github.com/mattn/gntp-send.git

$(PKG)_BINARY := $($(PKG)_DIR)/gntp-send
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/gntp-send

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;

$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNTPSEND_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GNTPSEND_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GNTPSEND_TARGET_BINARY)

$(PKG_FINISH)
