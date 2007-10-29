PACKAGE_LC:=xrelayd
PACKAGE_UC:=XRELAYD
$(PACKAGE_UC)_VERSION:=0.1
$(PACKAGE_INIT_BIN)
$(PACKAGE_UC)_SOURCE:=xrelayd-$($(PACKAGE_UC)_VERSION).tar.gz
$(PACKAGE_UC)_SITE:=http://znerol.ch/files
$(PACKAGE_UC)_BINARY:=$($(PACKAGE_UC)_DIR)/xrelayd
$(PACKAGE_UC)_TARGET_BINARY:=$($(PACKAGE_UC)_DEST_DIR)/usr/sbin/xrelayd

$(PACKAGE_SOURCE_DOWNLOAD)
$(PACKAGE_UNPACKED)
$(PACKAGE_CONFIGURED_NOP)

$($(PACKAGE_UC)_BINARY): $($(PACKAGE_UC)_DIR)/.configured
	$(TARGET_CONFIGURE_ENV) \
		$(MAKE) -C $(XRELAYD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		LD="$(TARGET_CC)" \

$($(PACKAGE_UC)_TARGET_BINARY): $($(PACKAGE_UC)_BINARY)
	$(INSTALL_BINARY_STRIP)

xrelayd:

xrelayd-precompiled: uclibc xyssl-precompiled xrelayd $($(PACKAGE_UC)_TARGET_BINARY) 

xrelayd-clean:
	-$(MAKE) -C $(XRELAYD_DIR) clean

xrelayd-uninstall: 
	rm -f $(XRELAYD_TARGET_BINARY)

$(PACKAGE_FINI)
