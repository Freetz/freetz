$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_RADVD_VERSION_ABANDON),1.9.3,2.19))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.$(if $(FREETZ_PACKAGE_RADVD_VERSION_ABANDON),gz,xz)
$(PKG)_HASH_ABANDON:=054fbd9c9823e04663b2a79966b8a061b65e6c508150dc225afcce242cbb2cd7
$(PKG)_HASH_CURRENT:=564e04597f71a9057d02290da0dd21b592d277ceb0e7277550991d788213e240
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_RADVD_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://radvd.litech.org/dist,https://github.com/radvd-project/radvd/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://radvd.litech.org/
### MANPAGE:=https://linux.die.net/man/5/radvd.conf
### CHANGES:=https://github.com/radvd-project/radvd/blob/master/CHANGES
### CVSREPO:=https://github.com/radvd-project/radvd

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg)
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/$(pkg)

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_RADVD_VERSION_ABANDON),libdaemon)
$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_RADVD_VERSION_ABANDON),abandon,current)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RADVD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $($(PKG)_DIR) clean

$(pkg)-uninstall:
	$(RM) $(RADVD_TARGET_BINARY)

$(PKG_FINISH)
