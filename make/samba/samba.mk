$(call PKG_INIT_BIN, 3.0.37)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=11ed2bfef4090bd5736b194b43f67289
$(PKG)_SITE:=http://samba.org/samba/ftp/stable
$(PKG)_BUILD_SUBDIR:=source

$(PKG)_STARTLEVEL=80

$(PKG)_BINARIES_ALL := smbpasswd smbd nmbd
$(PKG)_BINARIES := $(filter-out $(if $(FREETZ_PACKAGE_NMBD),,nmbd),$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/source/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/sbin/%)
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/sbin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON+= popt

ifneq ($(FREETZ_TARGET_IPV6_SUPPORT),y)
$(PKG)_CONFIGURE_ENV += libreplace_cv_HAVE_IPV6=no
endif
$(PKG)_CONFIGURE_ENV += ac_cv_func_prctl=no
$(PKG)_CONFIGURE_ENV += samba_cv_USE_SETRESUID=yes
$(PKG)_CONFIGURE_ENV += SMB_BUILD_CC_NEGATIVE_ENUM_VALUES=yes

$(PKG)_CONFIGURE_OPTIONS += --disable-swat
$(PKG)_CONFIGURE_OPTIONS += --disable-cups
$(PKG)_CONFIGURE_OPTIONS += --disable-iprint
$(PKG)_CONFIGURE_OPTIONS += --disable-pie
$(PKG)_CONFIGURE_OPTIONS += --disable-relro
$(PKG)_CONFIGURE_OPTIONS += --disable-fam
$(PKG)_CONFIGURE_OPTIONS += --disable-avahi
$(PKG)_CONFIGURE_OPTIONS += --disable-gnutls
$(PKG)_CONFIGURE_OPTIONS += --without-ldap
$(PKG)_CONFIGURE_OPTIONS += --without-ads
$(PKG)_CONFIGURE_OPTIONS += --without-cifsmount
$(PKG)_CONFIGURE_OPTIONS += --without-cifsupcall
$(PKG)_CONFIGURE_OPTIONS += --without-sys-quotas
$(PKG)_CONFIGURE_OPTIONS += --without-utmp
$(PKG)_CONFIGURE_OPTIONS += --without-cluster-support
$(PKG)_CONFIGURE_OPTIONS += --without-acl-support
$(PKG)_CONFIGURE_OPTIONS += --without-sendfile-support
$(PKG)_CONFIGURE_OPTIONS += --without-wbclient
$(PKG)_CONFIGURE_OPTIONS += --without-winbind
$(PKG)_CONFIGURE_OPTIONS += --with-krb5=no
$(PKG)_CONFIGURE_OPTIONS += --with-included-popt=no
$(PKG)_CONFIGURE_OPTIONS += --with-privatedir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-configdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --with-piddir=/var/run
$(PKG)_CONFIGURE_OPTIONS += --with-syslog

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	for target in headers all; do \
	$(SUBMAKE) -C $(SAMBA_DIR)/source \
		RANLIB="$(TARGET_RANLIB)" \
		CODEPAGEDIR="/mod/usr/share/samba" \
		$$target; \
	done

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/sbin/%: $($(PKG)_DIR)/source/bin/%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SAMBA_DIR)/source clean
	$(RM) -r $(SAMBA_DIR)/source/bin

$(pkg)-uninstall:
	$(RM) $(SAMBA_BINARIES_ALL:%=$(SAMBA_DEST_DIR)/sbin/%)

$(PKG_FINISH)
