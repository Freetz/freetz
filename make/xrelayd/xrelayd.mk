$(call PKG_INIT_BIN, 0.2)
$(PKG)_SOURCE:=xrelayd-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=http://znerol.ch/files
$(PKG)_BINARY:=$($(PKG)_DIR)/xrelayd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/xrelayd

$(PKG)_DEPENDS_ON := xyssl


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C $(XRELAYD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)" \

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

xrelayd:

xrelayd-precompiled: uclibc xrelayd $($(PKG)_TARGET_BINARY) 

xrelayd-clean:
	-$(MAKE) -C $(XRELAYD_DIR) clean

xrelayd-uninstall: 
	rm -f $(XRELAYD_TARGET_BINARY)

$(PKG_FINISH)
