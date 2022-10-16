$(call PKG_INIT_BIN, 1.6)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=5de8c8e29aaa3fb9cc6b47bb27299f271354ebb72514e3accadc7d38b5bbaa72
$(PKG)_SITE:=https://github.com/stedolan/jq/releases/download/jq-$($(PKG)_VERSION)

$(PKG)_BINARY := $($(PKG)_DIR)/jq
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/jq

$(PKG)_PATCH_POST_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|LD)FLAGS)

$(PKG)_EXTRA_CFLAGS  += -Werror=implicit-function-declaration

$(PKG)_EXTRA_CFLAGS  += -ffunction-sections -fdata-sections
$(PKG)_EXTRA_LDFLAGS += -Wl,--gc-sections

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_JQ_WITH_RE_SUPPORT
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_JQ_STATIC

ifeq ($(strip $(FREETZ_PACKAGE_JQ_WITH_RE_SUPPORT)),y)
$(PKG)_DEPENDS_ON += libonig
else
$(PKG)_CONFIGURE_OPTIONS += --without-oniguruma
$(PKG)_CONFIGURE_ENV += ac_cv_header_oniguruma_h=no
endif

ifeq ($(strip $(FREETZ_PACKAGE_JQ_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-all-static
endif

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += $(foreach opt,j0 j1 y0 y1,ac_cv_funclib_$(opt)=no)

$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-valgrind
$(PKG)_CONFIGURE_OPTIONS += --disable-maintainer-mode

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JQ_DIR) \
		EXTRA_CFLAGS="$(JQ_EXTRA_CFLAGS)" \
		EXTRA_LDFLAGS="$(JQ_EXTRA_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(JQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(JQ_TARGET_BINARY)

$(PKG_FINISH)
