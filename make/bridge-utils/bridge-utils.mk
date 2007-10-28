PACKAGE_LC:=bridge-utils
PACKAGE_UC:=BRIDGE_UTILS
$(PACKAGE_UC)_VERSION:=1.2
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=bridge-utils-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://mesh.dl.sourceforge.net/sourceforge/bridge
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/brctl/brctl
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_TARGET_DIR)/root/sbin/brctl

$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += aclocal --force ;
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += libtoolize --force ;
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += autoconf --force ;
$(PACKAGE_UC)_CONFIGURE_PRE_CMDS += autoheader --force ;

$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-randomdev=/dev/random
$(PACKAGE_UC)_CONFIGURE_OPTIONS += --with-linux-headers=$(KERNEL_DIR)/linux/include


$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_CONFIGURE)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(BRIDGE_UTILS_DIR)

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	mkdir -p $(dir $@)
	$(INSTALL_BINARY_STRIP)

bridge-utils: uclibc $($(PACKAGE_UC)_TARGET_BINARY)

bridge-utils-precompiled: bridge-utils $($(PACKAGE_UC)_TARGET_BINARY)

bridge-utils-clean:
	-$(MAKE) -C $(BRIDGE_UTILS_DIR) clean

bridge-utils-uninstall:
	$(RM) $(BRIDGE_UTILS_TARGET_BINARY)

$(PACKAGE_FINI)
