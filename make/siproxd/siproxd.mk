$(call PKG_INIT_BIN, 0.8.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=a39bc2a06a1c9abb6118ca3482e98f3c
$(PKG)_SITE:=@SF/$(pkg)

$(PKG)_BINARY_BUILD_DIR := $($(PKG)_DIR)/src/$(pkg)
$(PKG)_BINARY_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/bin/$(pkg)

$(PKG)_MODULES_DIR := $(FREETZ_LIBRARY_PATH)/$(pkg)
$(PKG)_MODULES_ALL := defaulttarget fix_bogus_via logcall shortdial stun demo
$(PKG)_MODULES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_MODULES_ALL),PLUGIN)

$(PKG)_MODULES_SO_BUILD_DIR := $($(PKG)_MODULES:%=$($(PKG)_DIR)/src/.libs/plugin_%.so)
$(PKG)_MODULES_SO_TARGET_DIR := $($(PKG)_MODULES:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/plugin_%.so)
$(PKG)_MODULES_LA_BUILD_DIR := $($(PKG)_MODULES:%=$($(PKG)_DIR)/src/plugin_%.la)
$(PKG)_MODULES_LA_TARGET_DIR := $($(PKG)_MODULES:%=$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/plugin_%.la)

$(PKG)_NOT_INCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/plugin_%.so,$(filter-out $($(PKG)_MODULES),$($(PKG)_MODULES_ALL)))
$(PKG)_NOT_INCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/plugin_%.la,$(filter-out $($(PKG)_MODULES),$($(PKG)_MODULES_ALL)))

$(PKG)_DEPENDS_ON := libosip2 libtool

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

# use system libltdl, not the bundled one
$(PKG)_CONFIGURE_PRE_CMDS += rm -rf libltdl; $(SED) -i -r -e '/^SUBDIRS( )*=/s,libltdl,,g' Makefile.in; $(SED) -i -r -e 's,"[.][.]/libltdl/(ltdl[.]h)",<\1>,g' src/plugins.h;

$(PKG)_CONFIGURE_OPTIONS += --with-libosip-prefix="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --disable-debug

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SIPROXD_DIR) \
		all

$($(PKG)_BINARY_TARGET_DIR): $($(PKG)_BINARY_BUILD_DIR)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_SO_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $($(PKG)_DIR)/src/.libs/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_MODULES_LA_TARGET_DIR): $($(PKG)_DEST_DIR)$($(PKG)_MODULES_DIR)/%: $($(PKG)_DIR)/src/%
	$(INSTALL_FILE)
	sed -i -r \
		-e 's,$(TARGET_TOOLCHAIN_STAGING_DIR),,g' \
		-e 's,/usr/lib/siproxd,$(SIPROXD_MODULES_DIR),g' \
		-e 's,/usr/lib/lib([^.]+)[.]la,-l\1,g;s,-L/usr/lib/?,,g' \
		-e 's,(installed=)no,\1yes,g' \
		$@

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARY_TARGET_DIR)  $($(PKG)_MODULES_SO_TARGET_DIR) $($(PKG)_MODULES_LA_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(SIPROXD_DIR) clean
	$(RM) $(SIPROXD_DIR)/.configured

$(pkg)-uninstall:
	$(RM) -r $(SIPROXD_BINARY_TARGET_DIR) $(SIPROXD_DEST_DIR)$(SIPROXD_MODULES_DIR)

$(PKG_FINISH)
