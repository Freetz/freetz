$(call PKG_INIT_BIN, 0.1)
$(PKG)_SOURCE:=ldd-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=b0b2c4edee81ac65c9706f8982b15d3a798be7c2d3865d9a7abff1e493dfadb1
$(PKG)_SITE:=@MIRROR/

$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/ldd.c
$(PKG)_BINARY:=$($(PKG)_DIR)/ldd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ldd
$(PKG)_CATEGORY:=Debug helpers


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(FREETZ_LD_RUN_PATH) \
		$(TARGET_CC) \
		$(TARGET_CFLAGS) \
		-DUCLIBC_RUNTIME_PREFIX=\"/\" \
		$(LDD_SOURCE_FILE) -o $@ \
		$(SILENT)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LDD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(LDD_TARGET_BINARY)

$(PKG_FINISH)
