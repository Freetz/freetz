# based on buildroot SVN
$(call PKG_INIT_BIN, 4.81)
$(PKG)_SOURCE:=lsof_$($(PKG)_VERSION)_src.tar.bz2
$(PKG)_SITE:=ftp://lsof.itap.purdue.edu/pub/tools/unix/lsof
$(PKG)_DIR:=$(SOURCE_DIR)/lsof_$($(PKG)_VERSION)_src
$(PKG)_BINARY:=$($(PKG)_DIR)/lsof
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/lsof
$(PKG)_SOURCE_MD5:=f7112535c2588d08c9234f157f079676 


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(LSOF_DIR); echo n | $(TARGET_CONFIGURE_OPTS) DEBUG="$(TARGET_CFLAGS)" LSOF_CC="$(TARGET_CC)" \
		LSOF_INCLUDE=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include ./Configure linux)
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE) -C $(LSOF_DIR) \
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
