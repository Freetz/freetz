# Set to y if you want to build transmission from svn.
# You might need to update the patches yourself.
# Unsupported, use at your own risk!
TRANSMISSION_FROM_SVN:=n

ifeq ($(TRANSMISSION_FROM_SVN),y)
$(call PKG_INIT_BIN, 14714)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=svn://svn.transmissionbt.com/Transmission/tags/2.92

$(PKG)_PATCH_POST_CMDS += $(SED) -i -r -e '/^m4_define.+user_agent_prefix/s,[+],,g' -e '/^m4_define.+peer_id_prefix/s,[XZ]-,0-,g' configure.ac;
$(PKG)_PATCH_POST_CMDS += $(call POLARSSL_HARDCODE_VERSION,13,configure.ac)

$(PKG)_CONFIGURE_PRE_CMDS += AUTOGEN_SUBDIR_MODE=y ./autogen.sh;
else
$(call PKG_INIT_BIN, 2.92)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_SHA256:=3a8d045c306ad9acb7bf81126939b9594553a388482efa0ec1bfb67b22acd35f
$(PKG)_SITE:=http://download.transmissionbt.com/files,https://transmission.cachefly.net
$(PKG)_PATCH_POST_CMDS += $(call POLARSSL_HARDCODE_VERSION,13,configure)
endif

$(PKG)_PATCH_POST_CMDS += $(call POLARSSL_HARDCODE_VERSION,13,libtransmission/crypto-utils-polarssl.c cmake/FindPolarSSL.cmake)

$(PKG)_BINARIES_ALL_SHORT     := cli  daemon  remote  create  edit   show
$(PKG)_BINARIES_BUILD_SUBDIRS := cli/ daemon/ daemon/ utils/  utils/ utils/

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
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_POLARSSL),polarssl13)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL $(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL),FREETZ_OPENSSL_SHLIB_VERSION)
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_WITH_POLARSSL
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TRANSMISSION_STATIC

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)
# remove some optimization/debug/warning flags
$(PKG)_CONFIGURE_PRE_CMDS += $(foreach flag,-O[0-9] -g -ggdb3 -Winline,$(SED) -i -r -e 's,(C(XX)?FLAGS="[^"]*)$(flag)(( [^"]*)?"),\1\3,g' ./configure;)

ifeq ($(strip $(FREETZ_TARGET_UCLIBC_0_9_28)),y)
$(PKG)_CONFIGURE_PRE_CMDS += $(SED) -i -r -e 's,iconv_open,no_iconv_open_in_0928,' ./configure;
endif

$(PKG)_CONFIGURE_OPTIONS += --enable-cli
$(PKG)_CONFIGURE_OPTIONS += --disable-mac
$(PKG)_CONFIGURE_OPTIONS += --without-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --enable-lightweight
$(PKG)_CONFIGURE_OPTIONS += --enable-utp
$(PKG)_CONFIGURE_OPTIONS += --with-crypto=$(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_OPENSSL),openssl)$(if $(FREETZ_PACKAGE_TRANSMISSION_WITH_POLARSSL),polarssl)

# add EXTRA_(C|LD)FLAGS
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -name Makefile.in -type f -exec $(SED) -i -r -e 's,^(C|LD)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' \{\} \+;
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
