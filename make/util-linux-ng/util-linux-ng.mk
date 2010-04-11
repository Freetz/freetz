$(call PKG_INIT_BIN, 2.17.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://www.kernel.org/pub/linux/utils/util-linux-ng/v2.17
$(PKG)_SOURCE_MD5:=4635725a3eef1c57090bac8ea5e082e6

$(PKG)_BINARIES:=blkid findfs
# misc-utils/.libs when building dynamically linked binaries
$(PKG)_BINARIES_SUBDIR:=misc-utils
# Suffix to add to util-linux-ng' binaries in order to distinguish them from e2fsprogs' ones
$(PKG)_BINARIES_SUFFIX:=-ng
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/$($(PKG)_BINARIES_SUBDIR)/%)
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/sbin/%$($(PKG)_BINARIES_SUFFIX))

# silence '*LARGEFILE* redefined' warnings
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -type f -name "*.c" \
	-exec $(SED) -i -r -e 's|(\#define (_LARGEFILE(64)?_SOURCE))|\#ifndef \2\n\1\n\#endif|g' \{\} \+ ;

# The following values are the values valid for the 2.6.13.1 kernel.
# They are the same as the ones detected by configure (that's the reason they are commented out).
# 2.6.19.2-values are unknown.
#$(PKG)_CONFIGURE_ENV += util_cv_syscall_ioprio_set=no
#$(PKG)_CONFIGURE_ENV += util_cv_syscall_ioprio_get=no
#$(PKG)_CONFIGURE_ENV += util_cv_syscall_fallocate=no
#$(PKG)_CONFIGURE_ENV += util_cv_syscall_unshare=no

# Do not build any shared library to
# 1) prevent conflicts with e2fsprogs' ones
# 2) force them to be linked in statically
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=no

# NB: REPLACE_LIBTOOL & POST_CMDS order is important
# don't know why, but libtool shipped with util-linux-ng has problems linking binaries
$(call REPLACE_LIBTOOL)
# modify replaced libtool so that it doesn't produce dynamic libraries
$(PKG)_CONFIGURE_POST_CMDS += \
	cat ./libtool | $(SED) -r -e 's,(build_libtool_libs=)yes,\1no,g' > ./libtool.static_libraries_only; \
	chmod 755 ./libtool.static_libraries_only; \
	ln -fs libtool.static_libraries_only ./libtool;

$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses

$(PKG)_CONFIGURE_OPTIONS += --disable-mount
$(PKG)_CONFIGURE_OPTIONS += --disable-fsck
$(PKG)_CONFIGURE_OPTIONS += --disable-agetty
$(PKG)_CONFIGURE_OPTIONS += --disable-cramfs #fsck.cramfs, mkfs.cramfs
$(PKG)_CONFIGURE_OPTIONS += --disable-switch_root
$(PKG)_CONFIGURE_OPTIONS += --disable-pivot_root
$(PKG)_CONFIGURE_OPTIONS += --disable-fallocate
$(PKG)_CONFIGURE_OPTIONS += --disable-unshare
$(PKG)_CONFIGURE_OPTIONS += --disable-rename
$(PKG)_CONFIGURE_OPTIONS += --disable-schedutils
$(PKG)_CONFIGURE_OPTIONS += --disable-wall

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(UTIL_LINUX_NG_DIR) V=1

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%$($(PKG)_BINARIES_SUFFIX): $($(PKG)_DIR)/$($(PKG)_BINARIES_SUBDIR)/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE1) -C $(UTIL_LINUX_NG_DIR) clean
	$(RM) $(UTIL_LINUX_NG_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(UTIL_LINUX_NG_BINARIES_TARGET_DIR)

$(PKG_FINISH)
