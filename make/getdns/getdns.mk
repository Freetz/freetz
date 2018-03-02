$(call PKG_INIT_BIN, 1.4.0)
$(PKG)_SOURCE:=getdns-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=de360cd554fdec4bae3f5afbb36145872b8ff7306ded5deb0905442c4909f7b3
$(PKG)_SITE:=https://getdnsapi.net/releases/getdns-1-4-0
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/stubby
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/stubby

$(PKG)_LIB_GETDNS := libgetdns.so.10.0.0
$(PKG)_LIB_GETDNS_BUILD_DIR := $($(PKG)_LIB_GETDNS:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_LIB_GETDNS_TARGET_DIR := $($(PKG)_LIB_GETDNS:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_CONFIGURE_OPTIONS += --without-libidn
$(PKG)_CONFIGURE_OPTIONS += --without-libidn2
$(PKG)_CONFIGURE_OPTIONS += --enable-stub-only
$(PKG)_CONFIGURE_OPTIONS += --with-stubby
$(PKG)_CONFIGURE_OPTIONS += --srcdir=$(FREETZ_BASE_DIR)/$($(PKG)_DIR)
$(PKG)_CONFIGURE_OPTIONS += --with-ssl=$(TARGET_TOOLCHAIN_STAGING_DIR)
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath

$(PKG)_EXTRA_CFLAGS += -std=gnu99

$(PKG)_DEPENDS_ON += openssl
$(PKG)_DEPENDS_ON += yaml

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GETDNS_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)
$($(PKG)_LIB_GETDNS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_GETDNS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GETDNS_DIR) clean
	$(RM) $(GETDNS_DIR)/.configured

$(pkg)-uninstall:
	$(RM) $(GETDNS_TARGET_BINARY)

$(PKG_FINISH)
