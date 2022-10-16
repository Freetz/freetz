$(call PKG_INIT_BIN, 0.2.1pre2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=f5eb4c393ce883b7f8dc8db2eebba50f3b97b3e7cb48d19aaee402417150142c
$(PKG)_SITE:=http://znerol.ch/files

$(PKG)_BINARY:=$($(PKG)_DIR)/xrelayd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/xrelayd

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_XRELAYD_GENSTUFF
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_XRELAYD_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_XRELAYD_STATIC_FULL

$(PKG)_DEPENDS_ON += polarssl12

$(PKG)_PATCH_POST_CMDS += $(call POLARSSL_HARDCODE_VERSION,12,Makefile xrelayd.c)

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -ffunction-sections -fdata-sections
$(PKG)_CFLAGS += -Werror-implicit-function-declaration
$(PKG)_CFLAGS += $(if $(FREETZ_PACKAGE_XRELAYD_GENSTUFF),-DGENSTUFF)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(XRELAYD_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(XRELAYD_CFLAGS)" \
		LD="$(TARGET_CC)" \
		LDFLAGS="-Wl,--gc-sections" \
		LIBS="$(if $(FREETZ_PACKAGE_XRELAYD_STATIC_FULL),-static,$(if $(FREETZ_PACKAGE_XRELAYD_STATIC),-Wl$(_comma)-static)) -lpolarssl12 $(if $(FREETZ_PACKAGE_XRELAYD_STATIC_FULL),,-Wl$(_comma)-Bdynamic)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(XRELAYD_DIR) clean

$(pkg)-uninstall:
	$(RM) $(XRELAYD_TARGET_BINARY)

$(PKG_FINISH)
