$(call PKG_INIT_BIN, 3.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=https://downloads.es.net/pub/iperf
$(PKG)_HASH:=72034ecfb6a7d6d67e384e19fb6efff3236ca4f7ed4c518d7db649c447e1ffd6
### WEBSITE:=https://iperf.fr/
### MANPAGE:=https://iperf.fr/iperf-doc.php
### CHANGES:=https://github.com/esnet/iperf/tags
### CVSREPO:=https://github.com/esnet/iperf

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,LDFLAGS|LIBS)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/iperf3
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/iperf

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPERF_WITH_OPENSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IPERF_STATIC

$(PKG)_CONFIGURE_OPTIONS += --disable-shared
ifeq ($(strip $(FREETZ_PACKAGE_IPERF_WITH_OPENSSL)),y)
$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_DEPENDS_ON += openssl
$(PKG)_CONFIGURE_OPTIONS += --with-openssl="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
ifeq ($(strip $(FREETZ_PACKAGE_IPERF_STATIC)),y)
$(PKG)_EXTRA_LIBS += $(OPENSSL_LIBCRYPTO_EXTRA_LIBS)
$(PKG)_EXTRA_LDFLAGS += -all-static
endif
else
$(PKG)_CONFIGURE_OPTIONS += --without-openssl
endif


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(IPERF_DIR)/src \
		EXTRA_LDFLAGS="$(IPERF_EXTRA_LDFLAGS)" \
		EXTRA_LIBS="$(IPERF_EXTRA_LIBS)" \
		iperf3

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE1) -C $(IPERF_DIR) clean
	$(RM) $(IPERF_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(IPERF_TARGET_BINARY)

$(PKG_FINISH)
