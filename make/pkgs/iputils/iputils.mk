$(call PKG_INIT_BIN, s20071127)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=dbbd87554d66e438245487ac31aa4a542a1c6c1ec8273cfacbbfeda09eb44a93
$(PKG)_SITE:=http://www.skbuff.net/iputils
$(PKG)_BINARY:=$($(PKG)_DIR)/traceroute6
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/traceroute6

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IPUTILS_DIR) traceroute6 tracepath6 tracepath ping ping6 \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) -D_GNU_SOURCE -Wstrict-prototypes" \
		LDLIBS=""

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(IPUTILS_DIR) clean

$(pkg)-uninstall:
	$(RM) $(IPUTILS_TARGET_BINARY)

$(PKG_FINISH)
