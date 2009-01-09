# based on buildroot SVN
$(call PKG_INIT_BIN, 4.78)
$(PKG)_SOURCE:=lsof_$($(PKG)_VERSION).dfsg.1.orig.tar.gz
$(PKG)_SITE:=http://ftp2.de.debian.org/debian/pool/main/l/lsof
$(PKG)_DIR:=$(SOURCE_DIR)/lsof-$($(PKG)_VERSION).dfsg.1
$(PKG)_BINARY:=$($(PKG)_DIR)/lsof
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lsof


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(LSOF_DIR); echo n | $(TARGET_CONFIGURE_OPTS) DEBUG="$(TARGET_CFLAGS)" LSOF_INCLUDE=$(TARGET_MAKE_PATH)/../usr/include ./Configure linux)
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LSOF_DIR) \
		CC=$(TARGET_CC) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="" \
		DEBUG="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) 
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) 

$(pkg)-clean:
	-$(MAKE) -C $(LSOF_DIR) clean

$(pkg)-uninstall: 
	$(RM) $(LSOF_TARGET_BINARY)

$(PKG_FINISH)
