$(call PKG_INIT_BIN, 1.10)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=0a05fc528aae1c52046c846d990d26ff
$(PKG)_SITE:=http://freetz.magenbrot.net
$(PKG)_BINARY:=$($(PKG)_DIR)/mount.cifs
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/mount.cifs
$(PKG)_STARTLEVEL=50

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	(cd $(CIFSMOUNT_DIR); \
		$(TARGET_CC) $(TARGET_CFLAGS) -o mount.cifs mount.cifs.c \
	)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	[ "$(FREETZ_PACKAGE_CIFSMOUNT_REMOVE_WEBIF)" == "y" ] \
		&& echo "usr/sbin/cifsmount" >> $@ \
		&& echo "usr/lib/cgi-bin/cifsmount.cgi" >> $@ \
		&& echo "etc/default.cifsmount" >> $@ \
		&& echo "etc/init.d/rc.cifsmount" >> $@; \
	touch $@

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(CIFSMOUNT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(CIFSMOUNT_TARGET_BINARY)

$(PKG_FINISH)
