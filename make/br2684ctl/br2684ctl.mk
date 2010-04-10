$(call PKG_INIT_BIN,20040226)
$(PKG)_SOURCE:=br2684ctl_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SITE:=http://ftp.debian.org/debian/pool/main/b/br2684ctl
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/$(pkg)-$($(PKG)_VERSION).orig
$(PKG)_BINARY:=$($(PKG)_DIR)/br2684ctl
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/sbin/br2684ctl
$(PKG)_SOURCE_MD5:=6eb4d8cd174e24a7c078eb4f594f5b69

$(PKG)_DEPENDS_ON := linux-atm

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_LAYOUT

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

ifneq ($(findstring ur8,$(FREETZ_KERNEL_LAYOUT)),)
BR2684CTL_OPTS := -DCONFIG_MIPS_UR8
endif

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BR2684CTL_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		OPTS="$(BR2684CTL_OPTS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(BR2684CTL_DIR) clean

$(pkg)-uninstall:
	$(RM) $(BR2684CTL_TARGET_BINARY)

$(PKG_FINISH)
