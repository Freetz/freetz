$(call PKG_INIT_LIB, 2b58f77ee27c60842054fd0e5dd67f5d00e89eb8)
$(PKG)_LIB_VERSION:=0.2.5
$(PKG)_SOURCE:=uClibc++-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=3d0a08bdad8942154ec49edec1274b2d942cf80b74bd5d4dbd2d81970a57e441
$(PKG)_SITE:=http://git.uclibc.org/uClibc++/snapshot

$(PKG)_BINARY:=$($(PKG)_DIR)/src/libuClibc++.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuClibc++.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libuClibc++.so.$($(PKG)_LIB_VERSION)

$(PKG)_STAGING_WRAPPER:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++-uc

$(PKG)_COMMON_MAKE_OPTS := -C $($(PKG)_DIR)
$(PKG)_COMMON_MAKE_OPTS += CPU_CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_COMMON_MAKE_OPTS += CROSS_COMPILE="$(TARGET_CROSS)"
ifeq ($(strip $(FREETZ_VERBOSITY_LEVEL)),2)
$(PKG)_COMMON_MAKE_OPTS += V=2
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libuClibc__WITH_WCHAR

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	cp $(UCLIBCXX_MAKE_DIR)/Config.uclibc++ $(UCLIBCXX_DIR)/.config
	$(call PKG_EDIT_CONFIG, \
		UCLIBCXX_HAS_WCHAR=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
		UCLIBCXX_SUPPORT_WCIN=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
		UCLIBCXX_SUPPORT_WCOUT=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
		UCLIBCXX_SUPPORT_WCERR=$(FREETZ_LIB_libuClibc__WITH_WCHAR) \
	) $(UCLIBCXX_DIR)/.config
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(UCLIBCXX_COMMON_MAKE_OPTS)

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) $(UCLIBCXX_COMMON_MAKE_OPTS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install-include install-lib
	touch -c $@

$($(PKG)_STAGING_WRAPPER): $($(PKG)_BINARY)
	$(SUBMAKE) $(UCLIBCXX_COMMON_MAKE_OPTS) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr" \
		install-bin
	$(SED)  -i \
		-e 's,-I/include/uClibc++,-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uClibc++,g' \
		-e 's,-L/lib/,-L$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/,g' \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/g++-uc
	mv $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/g++-uc $@
	ln -sf $(notdir $@) $(dir $@)$(GNU_TARGET_NAME)-g++-uc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY) $($(PKG)_STAGING_WRAPPER)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) $(UCLIBCXX_COMMON_MAKE_OPTS) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/*-g++-uc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuClibc++* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uClibc++

$(pkg)-uninstall:
	$(RM) $(UCLIBCXX_TARGET_DIR)/libuClibc++*.so*

$(PKG_FINISH)
