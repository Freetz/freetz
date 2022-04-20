$(call PKG_INIT_BIN, $(if $(FREETZ_TARGET_UCLIBC_0),0.80,852e5617fbf331cf292723702161f0ac9afe257c))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256_ABANDON:=76bbdd97faf3b805933a50858549ddba895911d6891c6cc51db472567cff0ec0
$(PKG)_SOURCE_SHA256_CURRENT:=3f4d97830d87b613b1040645e7c5188520e681fc01866cbfa4825de8d72f7723
$(PKG)_SOURCE_SHA256:=$(MTR_SOURCE_SHA256_$(if $(FREETZ_TARGET_UCLIBC_0),ABANDON,CURRENT))
$(PKG)_SITE_ABANDON:=https://www.bitwizard.nl/mtr/files
$(PKG)_SITE_CURRENT:=git@https://github.com/traviscross/mtr.git
$(PKG)_SITE:=$(MTR_SITE_$(if $(FREETZ_TARGET_UCLIBC_0),ABANDON,CURRENT))
### WEBSITE:=https://www.bitwizard.nl/mtr/
### MANPAGE:=https://linux.die.net/man/8/mtr
### CHANGES:=https://github.com/traviscross/mtr/blob/master/NEWS
### CVSREPO:=https://github.com/traviscross/mtr

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_TARGET_UCLIBC_0),abandon,current)

$(PKG)_BINARY:=mtr $(if $(FREETZ_TARGET_UCLIBC_0),,mtr-packet)
$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_BINARY:%=$($(PKG)_DIR)/%)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_BINARY:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

# new versions have no release-tar but only a git tag
$(PKG)_CONFIGURE_PRE_CMDS += $(if $(FREETZ_TARGET_UCLIBC_0),,./bootstrap.sh;)

$(PKG)_CONFIGURE_ENV += ac_cv_lib_cap_cap_set_proc=no

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
ifeq ($(FREETZ_TARGET_UCLIBC_0),y)
$(PKG)_CONFIGURE_OPTIONS += --with-ncurses
#$(PKG)_CONFIGURE_OPTIONS += --with-ipinfo
#$(PKG)_CONFIGURE_OPTIONS += --without-libasan
$(PKG)_CONFIGURE_OPTIONS += --without-jansson
endif
$(PKG)_CONFIGURE_OPTIONS += --without-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-gtktest
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),,--disable-ipv6)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(MTR_DIR)

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/sbin/%: $($(PKG)_DIR)/$($(PKG)_BUILD_SUBDIR)%
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(MTR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(MTR_BINARY_TARGET_DIR)

$(PKG_FINISH)

