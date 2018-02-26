$(call PKG_INIT_BIN, a5b5cbefb8)
$(PKG)_SOURCE:=$($(PKG)_VERSION).tar.xz
$(PKG)_SITE:=git@https://github.com/stedolan/jq

$(PKG)_BINARY_NAME := jq
$(PKG)_BINARY := $($(PKG)_DIR)/$($(PKG)_BINARY_NAME)
$(PKG)_TARGET_BINARY := $($(PKG)_DEST_DIR)/usr/bin/$($(PKG)_BINARY_NAME)

$(PKG)_CFLAGS += -W -Wall -std=c99 -O2 -ffunction-sections -fdata-sections
$(PKG)_LDFLAGS += -Wl,--gc-sections

# we can check format arguments further, because patches are supplied to silence these warnings at the right places
$(PKG)_CFLAGS += -Wformat=2

# we need BSD_SOURCE for 'strdup' (it's heavily used in the original sources)
$(PKG)_CFLAGS += -D_BSD_SOURCE

# and we need XOPEN_SOURCE for 'fileno', too
$(PKG)_CFLAGS += -D_XOPEN_SOURCE

# errors are enforced on implicit function declarations, otherwise 'configure' doesn't detect absence of bessel
# functions j0, j1, y0 and y1 - using pedantic error reporting isn't an alternative here, because there're other
# incompatibilities in the original source
$(PKG)_CFLAGS += -Werror=implicit-function-declaration

# the configuration cache may declare j0, j1, y0 and y1 as present, if first check was made without error on
# implicit function declarations (maybe without C99 enforced, too) - should overwrite the previous
# TARGET_CONFIGURE_OPTIONS entry for 'cache-file' without side-effects (beside more efforts for 'configure')
$(PKG)_CONFIGURE_OPTIONS += --cache-file=/dev/null

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_JQ_STATIC
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_JQ_WITH_RE_SUPPORT

ifeq ($(strip $(FREETZ_PACKAGE_JQ_WITH_RE_SUPPORT)),y)
$(PKG)_DEPENDS_ON += libonig
else
$(PKG)_CONFIGURE_ENV += WO_ONIGURUMA=1
endif

# we'll link 'libonig' and 'libm' dynamically or everything statically
ifeq ($(strip $(FREETZ_PACKAGE_JQ_STATIC)),y)
$(PKG)_CONFIGURE_OPTIONS += --enable-all-static
else
$(PKG)_CONFIGURE_PRE_CMDS += sed -i -r -e 's,-static-libtool-libs,-static,g' ./Makefile.in;
endif

$(PKG)_CONFIGURE_OPTIONS += --disable-silent-rules
$(PKG)_CONFIGURE_OPTIONS += --disable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-valgrind
$(PKG)_CONFIGURE_OPTIONS += CFLAGS="$(TARGET_CFLAGS) $($(PKG)_CFLAGS)"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(JQ_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS) $(JQ_CFLAGS)" \
		LDFLAGS="$(TARGET_LDFLAGS) $(JQ_LDFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(SUBMAKE) -C $(JQ_DIR) clean

$(pkg)-uninstall:
	$(RM) $(JQ_TARGET_BINARY)

$(PKG_FINISH)
