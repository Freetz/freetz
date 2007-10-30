$(eval $(call PKG_INIT_BIN, 0.1))
$(PKG)_SOURCE:=ldd-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://dsmod.magenbrot.net
$(PKG)_SOURCE_FILE:=$($(PKG)_DIR)/ldd.c
$(PKG)_BINARY:=$($(PKG)_DIR)/ldd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ldd

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	    $(TARGET_CC) \
	    $(TARGET_CFLAGS) \
	    -DUCLIBC_RUNTIME_PREFIX=\ \
	    $(LDD_SOURCE_FILE) -o $@ 

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	mkdir -p $(dir $(LDD_TARGET_BINARY))
	$(INSTALL_BINARY_STRIP)

ldd:

ldd-precompiled: uclibc ldd $($(PKG)_TARGET_BINARY)

ldd-clean:
	-$(MAKE) -C $(LDD_DIR) clean
	$(RM) $(PACKAGES_BUILD_DIR)/$(LDD_PKG_SOURCE)

ldd-uninstall:
	$(RM) $(LDD_TARGET_BINARY)

$(PKG_FINISH)
