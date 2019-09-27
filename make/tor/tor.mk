$(call PKG_INIT_BIN, 0.4.1.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_SHA256:=2a88524ce426079fb9b828bc1b789f2c8ade3ed53c130851102debc3518bed71
$(PKG)_SITE:=https://www.torproject.org/dist

$(PKG)_BINARY:=$($(PKG)_DIR)/src/app/tor
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/tor

$(PKG)_DEPENDS_ON += zlib openssl libevent

$(PKG)_GEOIPDB_DIR := /usr/share/tor
$(PKG)_GEOIPDB_ALL := geoip geoip6

$(PKG)_GEOIPDB := $(if $(FREETZ_PACKAGE_TOR_GEOIP_V4),geoip) $(if $(FREETZ_PACKAGE_TOR_GEOIP_V6),geoip6)
$(PKG)_GEOIPDB_BUILD_DIR := $($(PKG)_GEOIPDB:%=$($(PKG)_DIR)/src/config/%)
$(PKG)_GEOIPDB_TARGET_DIR := $($(PKG)_GEOIPDB:%=$($(PKG)_DEST_DIR)$($(PKG)_GEOIPDB_DIR)/%)

$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_GEOIPDB_DIR)/%,$(filter-out $($(PKG)_GEOIPDB),$($(PKG)_GEOIPDB_ALL)))
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TOR_GEOIP_V4
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_TOR_GEOIP_V6

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
$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS)

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

$($(PKG)_GEOIPDB_BUILD_DIR): $($(PKG)_DIR)/.unpacked

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_GEOIPDB_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_GEOIPDB_DIR)/%: $($(PKG)_DIR)/src/config/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_GEOIPDB_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(TOR_DIR) clean

$(pkg)-uninstall:
	$(RM) -r $(TOR_TARGET_BINARY) $(TOR_DEST_DIR)$(MNISATIP_GEOIPDB_DIR)

$(PKG_FINISH)
