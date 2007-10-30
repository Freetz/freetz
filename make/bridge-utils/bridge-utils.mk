$(eval $(call PKG_INIT_BIN,1.2))
$(PKG)_SOURCE:=bridge-utils-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/bridge
$(PKG)_BINARY:=$($(PKG)_DIR)/brctl/brctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/root/sbin/brctl

$(PKG)_CONFIGURE_PRE_CMDS += aclocal --force ;
$(PKG)_CONFIGURE_PRE_CMDS += libtoolize --force ;
$(PKG)_CONFIGURE_PRE_CMDS += autoconf --force ;
$(PKG)_CONFIGURE_PRE_CMDS += autoheader --force ;

$(PKG)_CONFIGURE_OPTIONS += --with-randomdev=/dev/random
$(PKG)_CONFIGURE_OPTIONS += --with-linux-headers=$(KERNEL_HEADERS_DIR)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BRIDGE_UTILS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

bridge-utils: uclibc $($(PKG)_TARGET_BINARY)

bridge-utils-precompiled: bridge-utils $($(PKG)_TARGET_BINARY)

bridge-utils-clean:
	-$(MAKE) -C $(BRIDGE_UTILS_DIR) clean

bridge-utils-uninstall:
	$(RM) $(BRIDGE_UTILS_TARGET_BINARY)

$(PKG_FINISH)
