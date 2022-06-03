$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_HTOP_VERSION_ABANDON),1.0.3,3.2.1))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.$(if $(FREETZ_PACKAGE_HTOP_VERSION_ABANDON),gz,xz)
$(PKG)_HASH_ABANDON:=055c57927f75847fdc222b5258b079a9542811a9dcf5421c615c7e17f55d1829
$(PKG)_HASH_CURRENT:=5a17121cf1c69d2f2e557c0b29d45a2c353ab983f644742e1c2e4ece15aa6cbb
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_HTOP_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/htop-dev/htop/releases/download/$($(PKG)_VERSION),https://hisham.hm/htop/releases/$($(PKG)_VERSION)
### WEBSITE:=https://htop.dev/
### MANPAGE:=https://linux.die.net/man/1/htop
### CHANGES:=https://github.com/htop-dev/htop/blob/main/ChangeLog
### CVSREPO:=https://github.com/htop-dev/htop 

$(PKG)_BINARY:=$($(PKG)_DIR)/htop
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/htop

$(PKG)_DEPENDS_ON += ncurses

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_HTOP_VERSION_ABANDON

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_HTOP_VERSION_ABANDON),abandon,current)

ifeq ($(FREETZ_PACKAGE_HTOP_VERSION_ABANDON),y)
$(PKG)_CONFIGURE_ENV += ac_cv_file__proc_stat=yes
$(PKG)_CONFIGURE_ENV += ac_cv_file__proc_meminfo=yes

$(PKG)_CONFIGURE_OPTIONS += --disable-unicode
ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_CONFIGURE_OPTIONS += --disable-native-affinity
endif

else

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh $(SILENT);

$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-unicode
$(PKG)_CONFIGURE_OPTIONS += --disable-hwloc
$(PKG)_CONFIGURE_OPTIONS += --disable-pcp
$(PKG)_CONFIGURE_OPTIONS += --disable-sensors
$(PKG)_CONFIGURE_OPTIONS += --disable-capabilities
$(PKG)_CONFIGURE_OPTIONS += --disable-openvz
$(PKG)_CONFIGURE_OPTIONS += --disable-vserver
$(PKG)_CONFIGURE_OPTIONS += --disable-ancient-vserver
$(PKG)_CONFIGURE_OPTIONS += --disable-delayacct
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(HTOP_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(HTOP_DIR) clean
	$(RM) $(HTOP_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(HTOP_TARGET_BINARY)

$(PKG_FINISH)
