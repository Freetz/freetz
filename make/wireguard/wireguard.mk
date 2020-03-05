$(call PKG_INIT_BIN, 1.0.20200206)
$(PKG)_SOURCE:=wireguard-tools-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=f5207248c6a3c3e3bfc9ab30b91c1897b00802ed861e1f9faaed873366078c64
$(PKG)_SITE:=https://git.zx2c4.com/wireguard-tools/snapshot

$(PKG)_BINARY:=$($(PKG)_DIR)/src/wg
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wg

$(PKG)_EXTRA_CFLAGS += --function-section -fdata-sections -fstack-protector-strong
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG)_DEPENDS_ON += kernel 

$(PKG)_REBUILD_SUBOPTS += FREETZ_KERNEL_VERSION

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WIREGUARD_DIR)/src  \
		CC="$(TARGET_CC)" \
                EXTRA_CFLAGS="$(WIREGUARD_EXTRA_CFLAGS)" \
                EXTRA_LDFLAGS="$(WIREGUARD_EXTRA_LDFLAGS)"


$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)


$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(WIREGUARD_DIR)/src clean 

$(pkg)-uninstall:
	$(RM)  $(WIREGUARD_TARGET_BINARY) 

$(PKG_FINISH)
