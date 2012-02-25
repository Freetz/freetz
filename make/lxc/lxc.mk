$(call PKG_INIT_BIN, 0.7.4.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=f0a5345c8d9cb927cf15043a3cc1f413
$(PKG)_SITE:=http://dfn.dl.sourceforge.net/project/lxc/lxc/$(pkg)-$($(PKG)_VERSION)

$(PKG)_DEPENDS_ON := libcap

$(PKG)_BINARIES:=lxc-attach lxc-cgroup lxc-checkpoint lxc-console lxc-execute \
	lxc-freeze lxc-info lxc-kill lxc-monitor lxc-restart lxc-start lxc-stop \
	lxc-unfreeze lxc-unshare lxc-wait
$(PKG)_BINARIES2:=lxc-init
$(PKG)_LIBS:=liblxc.so
$(PKG)_LIBS_FULL_NAME:=liblxc.so.$($(PKG)_VERSION)
$(PKG)_SCRIPTS:=lxc-checkconfig lxc-create lxc-destroy lxc-ls lxc-netstat \
	lxc-ps lxc-setcap lxc-setuid lxc-version

$(PKG)_BUILD_BINARIES   :=$(patsubst %,$($(PKG)_DIR)/src/$(pkg)/%,$($(PKG)_BINARIES))
$(PKG)_BUILD_BINARIES2  :=$(patsubst %,$($(PKG)_DIR)/src/$(pkg)/%,$($(PKG)_BINARIES2))
$(PKG)_BUILD_SCRIPTS    :=$(patsubst %,$($(PKG)_DIR)/src/$(pkg)/%,$($(PKG)_SCRIPTS))
$(PKG)_BUILD_LIBS       :=$(patsubst %,$($(PKG)_DIR)/src/$(pkg)/%,$($(PKG)_LIBS))

$(PKG)_STAGING_BINARIES :=$(patsubst %,$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/%,$($(PKG)_BINARIES))
$(PKG)_STAGING_BINARIES2:=$(patsubst %,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg)/%,$($(PKG)_BINARIES2))
$(PKG)_STAGING_SCRIPTS  :=$(patsubst %,$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/%,$($(PKG)_SCRIPTS))
$(PKG)_STAGING_LIBS     :=$(patsubst %,$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%,$($(PKG)_LIBS_FULL_NAME))

$(PKG)_TARGET_BINARIES  :=$(patsubst %,$($(PKG)_DEST_USR_SBIN)/%,$($(PKG)_BINARIES))
$(PKG)_TARGET_BINARIES2 :=$(patsubst %,$($(PKG)_DEST_USR_LIB)/$(pkg)/%,$($(PKG)_BINARIES2))
$(PKG)_TARGET_SCRIPTS   :=$(patsubst %,$($(PKG)_DEST_USR_SBIN)/%,$($(PKG)_SCRIPTS))
$(PKG)_TARGET_LIBS      :=$(patsubst %,$($(PKG)_DEST_LIBDIR)/%,$($(PKG)_LIBS_FULL_NAME))

$(PKG)_CONFIGURE_OPTIONS += --disable-examples
$(PKG)_CONFIGURE_OPTIONS += --disable-doc
$(PKG)_CONFIGURE_OPTIONS += --with-linuxdir=$(realpath $(KERNEL_SOURCE_DIR))

$(PKG)_CONFIGURE_ENV += ac_cv_header_sys_capability_h=yes
$(PKG)_CONFIGURE_ENV += ac_cv_lib_cap_cap_set_proc=yes

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BUILD_BINARIES) $($(PKG)_BUILD_BINARIES2) $($(PKG)_BUILD_LIBS): \
		$($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LXC_DIR)

$($(PKG)_STAGING_BINARIES) $($(PKG)_STAGING_BINARIES2) $($(PKG)_STAGING_LIBS) $($(PKG)_STAGING_SCRIPTS): \
		$($(PKG)_BUILD_BINARIES) $($(PKG)_BUILD_BINARIES2) $($(PKG)_BUILD_LIBS) $($(PKG)_BUILD_SCRIPTS)
	$(SUBMAKE) -C $(LXC_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install

$(foreach binary,$($(PKG)_STAGING_BINARIES),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach binary,$($(PKG)_STAGING_BINARIES2),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/lib/$(pkg))))
$(foreach binary,$($(PKG)_STAGING_LIBS),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),$(FREETZ_LIBRARY_PATH))))

$($(PKG)_TARGET_SCRIPTS): $($(PKG)_STAGING_SCRIPTS)
	@mkdir -p $(dir $@)
	cp $^ $(dir $@)

$($(PKG)_DEST_USR_LIB)/$(pkg):
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lxc $(LXC_DEST_USR_LIB)/lxc

$(pkg):

$(pkg)-precompiled: \
	$($(PKG)_TARGET_BINARIES) $($(PKG)_TARGET_BINARIES2) $($(PKG)_TARGET_SCRIPTS) $($(PKG)_TARGET_LIBS) \
	$($(PKG)_DEST_USR_LIB)/$(pkg)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LXC_DIR) clean
	$(RM) -r \
		$(LXC_STAGING_BINARIES) \
		$(LXC_STAGING_BINARIES2) \
		$(LXC_STAGING_LIBS) \
		$(LXC_STAGING_SCRIPTS) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/lxc

$(pkg)-uninstall:
	$(RM) -r \
		$(LXC_TARGET_BINARIES) \
		$(LXC_TARGET_BINARIES2) \
		$(LXC_TARGET_LIBS) \
		$(LXC_TARGET_SCRIPTS) \
		$(LXC_DEST_USR_LIB)/lxc

$(PKG_FINISH)
