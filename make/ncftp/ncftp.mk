$(call PKG_INIT_BIN, 3.2.3)
$(PKG)_SOURCE:=ncftp-$($(PKG)_VERSION)-src.tar.gz
$(PKG)_SITE:=ftp://ftp.ncftp.com/ncftp/
$(PKG)_BINARY:=$($(PKG)_DIR)/bin/ncftp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ncftp
$(PKG)_GET:=$($(PKG)_DIR)/bin/ncftpget
$(PKG)_TARGET_GET:=$($(PKG)_DEST_DIR)/usr/bin/ncftpget
$(PKG)_PUT:=$($(PKG)_DIR)/bin/ncftpput
$(PKG)_TARGET_PUT:=$($(PKG)_DEST_DIR)/usr/bin/ncftpput
$(PKG)_BATCH:=$($(PKG)_DIR)/bin/ncftpbatch
$(PKG)_TARGET_BATCH:=$($(PKG)_DEST_DIR)/usr/bin/ncftpbatch
$(PKG)_LS:=$($(PKG)_DIR)/bin/ncftpls
$(PKG)_TARGET_LS:=$($(PKG)_DEST_DIR)/usr/bin/ncftpls

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(NCFTP_DIR) \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_TARGET_GET): $($(PKG)_GET)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_TARGET_PUT): $($(PKG)_PUT)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_TARGET_BATCH): $($(PKG)_BATCH)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_TARGET_LS): $($(PKG)_LS)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) \
		    $($(PKG)_TARGET_GET) \
		    $($(PKG)_TARGET_PUT) \
		    $($(PKG)_TARGET_BATCH) \
		    $($(PKG)_TARGET_LS)
		  
$(pkg)-clean:
	-$(MAKE) -C $(NCFTP_DIR) clean
	$(RM) $(NCFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NCFTP_TARGET_BINARY) \
	      $(NCFTP_TARGET_GET) \
	      $(NCFTP_TARGET_PUT) \
	      $(NCFTP_TARGET_BATCH) \
	      $(NCFTP_TARGET_LS)

$(PKG_FINISH)
