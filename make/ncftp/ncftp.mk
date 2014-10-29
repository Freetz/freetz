$(call PKG_INIT_BIN, 3.2.5)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION)-src.tar.bz2
$(PKG)_SOURCE_MD5:=b05c7a6d5269c04891f02f43d4312b30
$(PKG)_SITE:=ftp://ftp.$(pkg).com/$(pkg)/

$(PKG)_BINARIES_ALL := ncftp ncftpget ncftpput ncftpbatch ncftpls
# ncftp is always included
$(PKG)_BINARIES := ncftp $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL),WITH)
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)
$(PKG)_EXCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_CONFIGURE_ENV += wi_cv_shared_libgcc=yes
$(PKG)_CONFIGURE_ENV += wi_cv_unix_domain_sockets=yes
$(PKG)_CONFIGURE_ENV += wi_cv_look_for_resolv=no
# the values below are the correct ones, they are equal to the guessed ones
$(PKG)_CONFIGURE_ENV += wi_cv_snprintf_terminates=yes
$(PKG)_CONFIGURE_ENV += wi_cv_snprintf_returns_ptr=no

$(PKG)_CONFIGURE_OPTIONS += --without-curses
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(NCFTP_DIR)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(NCFTP_DIR) clean
	$(RM) $(NCFTP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(NCFTP_BINARIES_ALL:%=$(NCFTP_DEST_DIR)/usr/bin/%)

$(PKG_FINISH)
