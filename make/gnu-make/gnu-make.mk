$(call PKG_INIT_BIN, 3.81)
$(PKG)_SOURCE:=make-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://ftp.gnu.org/pub/gnu/make
$(PKG)_DIR:=$(SOURCE_DIR)/make-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/make
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/make
$(PKG)_SOURCE_MD5:=354853e0b2da90c527e35aabb8d6f1e6

$(PKG)_CONFIGURE_ENV += make_cv_sys_gnu_glob=no
$(PKG)_CONFIGURE_ENV += GLOBINC='-Iglob/'
$(PKG)_CONFIGURE_ENV += GLOBLIB=glob/libglob.a

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(GNU_MAKE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(MAKE) -C $(GNU_MAKE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GNU_MAKE_TARGET_BINARY)

$(PKG_FINISH)
