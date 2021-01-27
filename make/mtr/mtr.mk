$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_MTR_VERSION_ABANDON),0.80,0.94))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5_ABANDON:=fa68528eaec1757f52bacf9fea8c68a9
$(PKG)_SOURCE_MD5_CURRENT:=0943067bce52019fb96de967a9db1db8
$(PKG)_SOURCE_MD5:=$(MTR_SOURCE_MD5_$(if $(FREETZ_PACKAGE_MTR_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=ftp://ftp.bitwizard.nl/mtr,https://github.com/traviscross/mtr/releases/tag/v$($(PKG)_VERSION)

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_MTR_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY:=mtr $(if $(FREETZ_PACKAGE_MTR_VERSION_ABANDON),,mtr-packet)
$(PKG)_BINARY_BUILD_DIR:=$($(PKG)_BINARY:%=$($(PKG)_DIR)/%)
$(PKG)_BINARY_TARGET_DIR:=$($(PKG)_BINARY:%=$($(PKG)_DEST_DIR)/usr/sbin/%)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-static
ifeq ($(FREETZ_PACKAGE_MTR_VERSION_ABANDON),y)
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
