$(call PKG_INIT_BIN, $(if $(FREETZ_SAMBA_VERSION_3_0),3.0.37,3.6.23))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5_3.0.37:=11ed2bfef4090bd5736b194b43f67289
$(PKG)_SOURCE_MD5_3.6.23:=2f7aee1dc5d31aefcb364600915b31dc
$(PKG)_SOURCE_MD5:=$($(PKG)_SOURCE_MD5_$($(PKG)_VERSION))
$(PKG)_SITE:=http://samba.org/samba/ftp/stable

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))

$(PKG)_BUILD_SUBDIR:=source$(if $(FREETZ_SAMBA_VERSION_3_0),,3)

$(PKG)_REBUILD_SUBOPTS += FREETZ_SAMBA_VERSION_3_0
$(PKG)_REBUILD_SUBOPTS += FREETZ_SAMBA_VERSION_3_6
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SAMBA_MAX_DEBUG_LEVEL
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_LFS

$(PKG)_BINARY:=samba_multicall
$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)/bin/$($(PKG)_BINARY)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_DEST_DIR)/sbin/$($(PKG)_BINARY)

$(PKG)_CLIENT_BINARIES:=smbclient nmblookup
$(PKG)_CLIENT_BINARIES_BUILD_DIR:=$($(PKG)_CLIENT_BINARIES:%=$($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)/bin/%)
$(PKG)_CLIENT_BINARIES_TARGET_DIR:=$($(PKG)_CLIENT_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_SYMLINKS:=smbd nmbd smbpasswd
$(PKG)_SYMLINKS_TARGET_DIR:=$($(PKG)_SYMLINKS:%=$($(PKG)_DEST_DIR)/sbin/%)

$(PKG)_CODEPAGES:=lowcase.dat upcase.dat valid.dat
$(PKG)_CODEPAGES_DIR:=/etc/samba
$(PKG)_CODEPAGES_BUILD_DIR:=$($(PKG)_CODEPAGES:%=$($(PKG)_DIR)/codepages/%)
$(PKG)_CODEPAGES_TARGET_DIR:=$($(PKG)_CODEPAGES:%=$($(PKG)_DEST_DIR)$($(PKG)_CODEPAGES_DIR)/%)

$(PKG)_DEPENDS_ON += popt ncurses readline
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_DEPENDS_ON += libiconv
$(PKG)_TARGET_LDFLAGS += -liconv
endif

include $(MAKE_DIR)/samba/samba$(if $(FREETZ_SAMBA_VERSION_3_0),30,36).mk.in

$(PKG)_TARGET_CFLAGS   += -ffunction-sections -fdata-sections
$(PKG)_TARGET_CPPFLAGS += -DMAX_DEBUG_LEVEL=$(FREETZ_PACKAGE_SAMBA_MAX_DEBUG_LEVEL)
# disable __location__ macro (expands to __FILE__ ":" __LINE__ per default) at debug levels -1 and 0 to reduce binary size
$(PKG)_TARGET_CPPFLAGS += $(if $(filter -1 0,$(FREETZ_PACKAGE_SAMBA_MAX_DEBUG_LEVEL)),-D__location__=\\\"\\\")
$(PKG)_TARGET_LDFLAGS  += -Wl,--gc-sections

$(PKG)_MAKE_FLAGS += EXTRA_CFLAGS="$(SAMBA_TARGET_CFLAGS)"
$(PKG)_MAKE_FLAGS += EXTRA_CPPFLAGS="$(SAMBA_TARGET_CPPFLAGS)"
$(PKG)_MAKE_FLAGS += EXTRA_LDFLAGS="$(SAMBA_TARGET_LDFLAGS)"
$(PKG)_MAKE_FLAGS += DYNEXP= PICFLAG=

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR) $($(PKG)_CLIENT_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	for target in $(if $(FREETZ_SAMBA_VERSION_3_0),headers) all; do \
	$(SUBMAKE) -C $(SAMBA_DIR)/$(SAMBA_BUILD_SUBDIR) \
		$(SAMBA_MAKE_FLAGS) \
		$$target; \
	done

$($(PKG)_CODEPAGES_BUILD_DIR): $($(PKG)_DIR)/.unpacked
	@touch $@

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_CLIENT_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)/bin/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_SYMLINKS_TARGET_DIR): $($(PKG)_BINARY_TARGET_DIR)
	ln -sf $(SAMBA_BINARY) $@

$($(PKG)_CODEPAGES_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_CODEPAGES_DIR)/%: $($(PKG)_DIR)/codepages/%
	$(INSTALL_FILE)

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_SAMBA_SMBD)" != "y" ] && echo -e "sbin/samba_multicall\nsbin/smbd\nsbin/smbpasswd" >> $@; \
	[ "$(FREETZ_PACKAGE_SAMBA_SMBD)" != "y" ] && echo -e "etc/default.samba\netc/init.d/rc.nmbd\netc/init.d/rc.samba\netc/init.d/rc.smbd\netc/samba_control\nusr/lib/cgi-bin/samba.cgi" >> $@; \
	[ "$(FREETZ_PACKAGE_SAMBA_SMBD)" != "y" -a "$(FREETZ_SAMBA_VERSION_3_6)" == "y" ] && echo -e "etc/samba/lowcase.dat\netc/samba/upcase.dat\netc/samba/valid.dat" >> $@; \
	[ "$(FREETZ_PACKAGE_SAMBA_NMBD)" != "y" ] && echo "sbin/nmbd" >> $@; \
	[ "$(FREETZ_PACKAGE_SAMBA_SMBCLIENT)" != "y" ] && echo "usr/bin/smbclient" >> $@; \
	[ "$(FREETZ_PACKAGE_SAMBA_NMBLOOKUP)" != "y" ] && echo "usr/bin/nmblookup" >> $@; \
	touch $@

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR) $($(PKG)_CLIENT_BINARIES_TARGET_DIR) $($(PKG)_SYMLINKS_TARGET_DIR) $(if $(FREETZ_SAMBA_VERSION_3_0),,$($(PKG)_CODEPAGES_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE) -C $(SAMBA_DIR)/$(SAMBA_BUILD_SUBDIR) clean
	$(RM) -r $(SAMBA_DIR)/$(SAMBA_BUILD_SUBDIR)/bin

$(pkg)-uninstall:
	$(RM) $(SAMBA_BINARY_TARGET_DIR) $(SAMBA_CLIENT_BINARIES_TARGET_DIR) $(SAMBA_SYMLINKS_TARGET_DIR) $(SAMBA_CODEPAGES_TARGET_DIR)

$(PKG_FINISH)
