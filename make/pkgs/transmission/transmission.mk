$(call PKG_INIT_BIN, 3.00)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=9144652fe742f7f7dd6657716e378da60b751aaeda8bef8344b3eefc4db255f2
$(PKG)_SITE:=https://github.com/transmission/transmission-releases/raw/master
### WEBSITE:=https://transmissionbt.com/download/
### MANPAGE:=https://github.com/transmission/transmission/wiki
### CHANGES:=https://github.com/transmission/transmission/releases
### CVSREPO:=https://github.com/transmission/transmission

$(PKG)_BINARIES_ALL_SHORT     := cli  daemon  remote  create  edit   show
$(PKG)_BINARIES_BUILD_SUBDIRS := cli/ daemon/ utils/  utils/  utils/ utils/

$(PKG)_BINARIES_ALL           := $(addprefix transmission-,$($(PKG)_BINARIES_ALL_SHORT))
$(PKG)_BINARIES               := $(addprefix transmission-,$(if $(FREETZ_PACKAGE_TRANSMISSION_CLIENT),cli,) $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL_SHORT)))
$(PKG)_BINARIES_BUILD_DIR     := $(addprefix $($(PKG)_DIR)/, $(join $($(PKG)_BINARIES_BUILD_SUBDIRS),$($(PKG)_BINARIES_ALL)))
$(PKG)_BINARIES_TARGET_DIR    := $($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

$(PKG)_WEBINTERFACE_DIR:=$($(PKG)_DIR)/web
$(PKG)_TARGET_WEBINTERFACE_DIR:=$($(PKG)_DEST_DIR)/usr/share/transmission-web-home
$(PKG)_TARGET_WEBINTERFACE_INDEX_HTML:=$($(PKG)_TARGET_WEBINTERFACE_DIR)/index.html

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))
ifneq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
$(PKG)_EXCLUDED += $($(PKG)_TARGET_WEBINTERFACE_DIR)
endif

$(PKG)_DEPENDS_ON += zlib curl libevent
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL),openssl)
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_MBEDTLS),mbedtls)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL $(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL),FREETZ_OPENSSL_SHLIB_VERSION)
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_WITH_MBEDTLS
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
# remove some optimization/debug/warning flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g -ggdb3 -Winline,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,iconv_open,no_iconv_open_in_0928,' ./configure;
endif

ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WITH_MBEDTLS)),y)
$(PKG)_CONFIGURE_ENV += MBEDTLS_CFLAGS="-D_MBEDTLS_DUMMY_"
$(PKG)_CONFIGURE_ENV += MBEDTLS_LIBS="-lmbedcrypto"
endif

$(PKG)_CONFIGURE_OPTIONS += --enable-cli
$(PKG)_CONFIGURE_OPTIONS += --disable-mac
$(PKG)_CONFIGURE_OPTIONS += --without-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --enable-lightweight
$(PKG)_CONFIGURE_OPTIONS += --enable-utp
$(PKG)_CONFIGURE_OPTIONS += --with-crypto=$(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL),openssl)$(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_MBEDTLS),polarssl)

# add EXTRA_(C|LD)FLAGS
$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS)
$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -all-static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TRANSMISSION_DIR) \
		EXTRA_CFLAGS="$(TRANSMISSION_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(TRANSMISSION_EXTRA_LDFLAGS)"

$(foreach binary,$($(PKG)_BINARIES_BUILD_DIR),$(eval $(call INSTALL_BINARY_STRIP_RULE,$(binary),/usr/bin)))

$($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML): $($(PKG)_DIR)/.unpacked
ifeq ($(strip $(FREETZ_PACKAGE_TRANSMISSION_WEBINTERFACE)),y)
	mkdir -p $(TRANSMISSION_TARGET_WEBINTERFACE_DIR)
	$(call COPY_USING_TAR,$(TRANSMISSION_WEBINTERFACE_DIR),$(TRANSMISSION_TARGET_WEBINTERFACE_DIR),--exclude=LICENSE --exclude='Makefile*' .)
	chmod 644 $@
	touch $@
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_TARGET_WEBINTERFACE_INDEX_HTML)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TRANSMISSION_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(TRANSMISSION_BINARIES_ALL:%=$(TRANSMISSION_DEST_DIR)/usr/bin/%) \
		$(TRANSMISSION_TARGET_WEBINTERFACE_DIR)

$(PKG_FINISH)
