$(call PKG_INIT_BIN, 0.2.8.12)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=476f5074c2f77350010dcb52f6f8651d
$(PKG)_SITE:=https://www.torproject.org/dist

$(PKG)_BINARY:=$($(PKG)_DIR)/src/or/tor
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tor

$(PKG)_DEPENDS_ON += zlib openssl libevent

$(PKG)_CONFIGURE_ENV += tor_cv_malloc_zero_works=no
$(PKG)_CONFIGURE_ENV += tor_cv_null_is_zero=yes
$(PKG)_CONFIGURE_ENV += tor_cv_sign_extend=yes
$(PKG)_CONFIGURE_ENV += tor_cv_size_t_signed=no
$(PKG)_CONFIGURE_ENV += tor_cv_time_t_signed=yes
$(PKG)_CONFIGURE_ENV += tor_cv_twos_complement=yes
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__fasynchronous_unwind_tables=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__fstack_protector_all=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__Wstack_protector=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags___param_ssp_buffer_size_1=no
$(PKG)_CONFIGURE_ENV += tor_cv_cflags__fPIE=no
$(PKG)_CONFIGURE_ENV += tor_cv_ldflags__pie=no

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --disable-tool-name-check
$(PKG)_CONFIGURE_OPTIONS += --with-openssl-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --with-libevent-dir="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib"
$(PKG)_CONFIGURE_OPTIONS += --disable-unittests

$(PKG)_REBUILD_SUBOPTS += FREETZ_OPENSSL_SHLIB_VERSION
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TOR_STATIC

# touch some patched files to prevent auto*-tools from being executed
$(PKG)_PATCH_POST_CMDS += touch -t 200001010000.00 ./configure.ac;

# add EXTRA_(C|LD)FLAGS
$(PKG)_CONFIGURE_PRE_CMDS += find $(abspath $($(PKG)_DIR)) -name Makefile.in -type f -exec $(SED) -i -r -e 's,^(C|LD)FLAGS[ \t]*=[ \t]*@\1FLAGS@,& $$$$(EXTRA_\1FLAGS),' \{\} \+;

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

ifeq ($(strip $(FREETZ_PACKAGE_TOR_STATIC)),y)
$(PKG)_EXTRA_LDFLAGS += -static
endif

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(TOR_DIR) \
		EXTRA_CFLAGS="$(TOR_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(TOR_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TOR_DIR) clean

$(pkg)-uninstall:
	$(RM) $(TOR_TARGET_BINARY)

$(PKG_FINISH)
