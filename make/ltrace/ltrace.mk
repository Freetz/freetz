#LTRACE_SVN_REVISION:=81
#$(call PKG_INIT_BIN, 0.5_$(LTRACE_SVN_REVISION))
$(call PKG_INIT_BIN, 0.5.3)
$(PKG)_SOURCE:=ltrace_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=3fa7fe715ab879db08bd06d1d59fd90f
$(PKG)_SITE:=http://ftp.debian.org/pool/main/l/ltrace
$(PKG)_BINARY:=$($(PKG)_DIR)/ltrace
$(PKG)_CONF:=$($(PKG)_DIR)/etc/ltrace.conf
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/ltrace
$(PKG)_TARGET_CONF:=$($(PKG)_DEST_DIR)/etc/ltrace.conf

$(PKG)_DEPENDS_ON := libelf	

$(PKG)_CONFIGURE_PRE_CMDS += ln -sf ./mipsel sysdeps/linux-gnu/mips ;

$(PKG)_CONFIGURE_ENV += LD="$(TARGET_LD)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_CONF): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_CONF): $($(PKG)_CONF)
	mkdir -p $(dir $@)
	cp $< $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LTRACE_DIR) ARCH=mips

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_TARGET_CONF)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LTRACE_DIR) clean ARCH=mips

$(pkg)-uninstall:
	$(RM) $(LTRACE_TARGET_BINARY)
	$(RM) $(LTRACE_TARGET_CONF)

$(PKG_FINISH)
