$(call PKG_INIT_BIN, 3.2.3)
$(PKG)_SOURCE:=ncftp-$($(PKG)_VERSION)-src.tar.gz
$(PKG)_SOURCE_MD5:=f08238032ab247aa78f935edfc4db9fb
$(PKG)_SITE:=ftp://ftp.ncftp.com/ncftp/

$(PKG)_BINARIES_ALL := ncftp ncftpget ncftpput ncftpbatch ncftpls
# ncftp is always included
$(PKG)_BINARIES := ncftp $(strip $(foreach binary,$($(PKG)_BINARIES_ALL),$(if $(FREETZ_PACKAGE_$(PKG)_WITH_$(shell echo $(binary) | tr [a-z] [A-Z])),$(binary))))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CONFIGURE_OPTIONS += --without-curses
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses

$(PKG)_LIBS := -lresolv

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
	$(MAKE) -C $(NCFTP_DIR) \
	LIBS="$(NCFTP_LIBS)" \
	CC="$(TARGET_CC)" \
	CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE) -C $(NCFTP_DIR) clean
	$(RM) $(NCFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NCFTP_BINARIES_ALL:%=$(NCFTP_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
