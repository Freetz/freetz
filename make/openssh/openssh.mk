$(call PKG_INIT_BIN, 6.2p2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA1:=c2b4909eba6f5ec6f9f75866c202db47f3b501ba
$(PKG)_SITE:=ftp://ftp.openbsd.org/pub/OpenBSD/OpenSSH/portable

$(PKG)_BIN_BINARIES             := ssh scp ssh-add ssh-agent ssh-keygen ssh-keysign ssh-keyscan sftp
$(PKG)_BIN_BINARIES_INCLUDED    := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BIN_BINARIES))
$(PKG)_BIN_BINARIES_BUILD_DIR   := $(addprefix $($(PKG)_DIR)/,$($(PKG)_BIN_BINARIES))
$(PKG)_BIN_BINARIES_TARGET_DIR  := $(addprefix $($(PKG)_DEST_DIR)/usr/bin/,$($(PKG)_BIN_BINARIES))

$(PKG)_SBIN_BINARIES            := sshd
$(PKG)_SBIN_BINARIES_INCLUDED   := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_SBIN_BINARIES))
$(PKG)_SBIN_BINARIES_BUILD_DIR  := $(addprefix $($(PKG)_DIR)/,$($(PKG)_SBIN_BINARIES))
$(PKG)_SBIN_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/sbin/,$($(PKG)_SBIN_BINARIES))

$(PKG)_LIB_BINARIES             := sftp-server
$(PKG)_LIB_BINARIES_INCLUDED    := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_LIB_BINARIES))
$(PKG)_LIB_BINARIES_BUILD_DIR   := $(addprefix $($(PKG)_DIR)/,$($(PKG)_LIB_BINARIES))
$(PKG)_LIB_BINARIES_TARGET_DIR  := $(addprefix $($(PKG)_DEST_DIR)/usr/lib/,$($(PKG)_LIB_BINARIES))

$(PKG)_DEPENDS_ON := openssl zlib

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_OPENSSH_STATIC

$(PKG)_AC_VARIABLES := have_decl_LLONG_MAX search_logout search_openpty
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_MAKE_AC_VARIABLES_PACKAGE_SPECIFIC,$($(PKG)_AC_VARIABLES))

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENSSH_STATIC),--disable-shared,--enable-shared)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_OPENSSH_STATIC),--enable-static,--disable-static)
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-etc-default-login
$(PKG)_CONFIGURE_OPTIONS += --disable-lastlog
$(PKG)_CONFIGURE_OPTIONS += --disable-utmp
$(PKG)_CONFIGURE_OPTIONS += --disable-utmpx
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmp
$(PKG)_CONFIGURE_OPTIONS += --disable-wtmpx
$(PKG)_CONFIGURE_OPTIONS += --without-bsd-auth
$(PKG)_CONFIGURE_OPTIONS += --without-kerberos5

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BIN_BINARIES_BUILD_DIR) $($(PKG)_SBIN_BINARIES_BUILD_DIR) $($(PKG)_LIB_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(OPENSSH_DIR) \
		EXTRA_LDFLAGS="$(if $(FREETZ_PACKAGE_OPENSSH_STATIC),-static)" \
		all

$(foreach binary,$($(PKG)_BIN_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))
$(foreach binary,$($(PKG)_SBIN_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/sbin)))
$(foreach binary,$($(PKG)_LIB_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/lib)))

$($(PKG)_TARGET_DIR)/.exclude: $(TOPDIR)/.config
	@echo -n "" > $@; \
	for f in \
		$(addprefix usr/bin/,$(filter-out $(OPENSSH_BIN_BINARIES_INCLUDED),$(OPENSSH_BIN_BINARIES))) \
		$(addprefix usr/sbin/,$(filter-out $(OPENSSH_SBIN_BINARIES_INCLUDED),$(OPENSSH_SBIN_BINARIES))) \
		$(addprefix usr/lib/,$(filter-out $(OPENSSH_LIB_BINARIES_INCLUDED),$(OPENSSH_LIB_BINARIES))); \
	do \
		echo "$$f" >> $@; \
	done; \
	[ "$(FREETZ_PACKAGE_OPENSSH_sshd)" != "y" ] \
		&& echo "etc/default.openssh" >> $@ \
		&& echo "etc/init.d/rc.openssh" >> $@ \
		&& echo "usr/lib/cgi-bin/openssh.cgi" >> $@; \
	touch $@

$(pkg): $($(PKG)_TARGET_DIR)/.exclude

$(pkg)-precompiled: $($(PKG)_BIN_BINARIES_TARGET_DIR) $($(PKG)_SBIN_BINARIES_TARGET_DIR) $($(PKG)_LIB_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(OPENSSH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(OPENSSH_BIN_BINARIES_TARGET_DIR) $(OPENSSH_SBIN_BINARIES_TARGET_DIR) $(OPENSSH_LIB_BINARIES_TARGET_DIR)

$(PKG_FINISH)
