$(call PKG_INIT_BIN, 6.2)
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/cifs-utils-$($(PKG)_VERSION)
$(PKG)_SOURCE:=cifs-utils-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=6a83fe19e02266cb468ea3bf1cc0d007
$(PKG)_SITE:=http://ftp.samba.org/pub/linux-cifs/cifs-utils

$(PKG)_STARTLEVEL=50

$(PKG)_BINARY:=$($(PKG)_DIR)/mount.cifs
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/mount.cifs

$(PKG)_CONFIGURE_OPTIONS += --with-libcap-ng=no
$(PKG)_CONFIGURE_OPTIONS += --with-libcap=no

$(PKG)_CONFIGURE_OPTIONS += --disable-cifsupcall
$(PKG)_CONFIGURE_OPTIONS += --disable-cifscreds
$(PKG)_CONFIGURE_OPTIONS += --disable-cifsidmap
$(PKG)_CONFIGURE_OPTIONS += --disable-cifsacl
$(PKG)_CONFIGURE_OPTIONS += --disable-systemd

$(PKG)_CONFIGURE_OPTIONS += --disable-pie
$(PKG)_CONFIGURE_OPTIONS += --disable-relro

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(CIFSMOUNT_DIR)

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
