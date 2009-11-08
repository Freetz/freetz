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
$(PKG)_SOURCE_MD5:=f08238032ab247aa78f935edfc4db9fb 

$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NCFTP_WITH_NCFTPGET
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NCFTP_WITH_NCFTPPUT
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NCFTP_WITH_NCFTPBATCH
$(PKG)_CONFIG_SUBOPTS += FREETZ_PACKAGE_NCFTP_WITH_NCFTPLS

$(PKG)_CONFIGURE_OPTIONS += --without-curses
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses

NCFTP_LIBS := -lresolv

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NCFTP_DIR) \
	LIBS="$(NCFTP_LIBS)" \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_GET): $($(PKG)_GET)
ifeq ($(strip $(FREETZ_PACKAGE_NCFTP_WITH_NCFTPGET)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $($(PKG)_TARGET_GET)
endif

$($(PKG)_TARGET_PUT): $($(PKG)_PUT)
ifeq ($(strip $(FREETZ_PACKAGE_NCFTP_WITH_NCFTPPUT)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $($(PKG)_TARGET_PUT)
endif

$($(PKG)_TARGET_BATCH): $($(PKG)_BATCH)
ifeq ($(strip $(FREETZ_PACKAGE_NCFTP_WITH_NCFTPBATCH)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $($(PKG)_TARGET_BATCH)
endif

$($(PKG)_TARGET_LS): $($(PKG)_LS)
ifeq ($(strip $(FREETZ_PACKAGE_NCFTP_WITH_NCFTPLS)),y)
	$(INSTALL_BINARY_STRIP)
else
	$(RM) $($(PKG)_TARGET_LS)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) \
		      $($(PKG)_TARGET_GET) \
		      $($(PKG)_TARGET_PUT) \
		      $($(PKG)_TARGET_BATCH) \
		      $($(PKG)_TARGET_LS)
	  
$(pkg)-clean:
	-$(SUBMAKE) -C $(NCFTP_DIR) clean
	$(RM) $(NCFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NCFTP_TARGET_BINARY) \
	      $(NCFTP_TARGET_GET) \
	      $(NCFTP_TARGET_PUT) \
	      $(NCFTP_TARGET_BATCH) \
	      $(NCFTP_TARGET_LS)

$(PKG_FINISH)
