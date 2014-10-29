$(call PKG_INIT_BIN,1.2.3)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=1131dc5f27c4f3905a6e7ee0d594fd4d
$(PKG)_SITE:=@SF/nfs

$(PKG)_BINARIES            := exportfs mountd nfsd showmount
$(PKG)_BINARIES_BUILD_DIR  := $(addprefix $($(PKG)_DIR)/utils/, $(join $($(PKG)_BINARIES),$(addprefix /,$($(PKG)_BINARIES))))
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_DEPENDS_ON += tcp_wrappers

# IPv6 support requires TIRPC
#$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
#ifeq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
#$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6=yes
#else
$(PKG)_CONFIGURE_OPTIONS += --enable-ipv6=no
$(PKG)_CONFIGURE_OPTIONS += --disable-tirpc
#endif

$(PKG)_CONFIGURE_ENV += ac_cv_type_getgroups=gid_t
$(PKG)_CONFIGURE_ENV += ac_cv_func_getgroups_works=yes
$(PKG)_CONFIGURE_ENV += ac_cv_func_stat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_empty_string_bug=no
$(PKG)_CONFIGURE_ENV += ac_cv_func_lstat_dereferences_slashed_symlink=no

$(PKG)_CONFIGURE_OPTIONS += --disable-nfsv4
$(PKG)_CONFIGURE_OPTIONS += --disable-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-gss
$(PKG)_CONFIGURE_OPTIONS += --disable-uuid

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NFS_UTILS_DIR)

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NFS_UTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(NFS_UTILS_BINARIES_TARGET_DIR)

$(PKG_FINISH)
