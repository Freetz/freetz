$(call PKG_INIT_LIB, 7c90261eb9e5cff4ea3a4e5580e4f2bc7543cb21, uclibcxx)
$(PKG)_LIB_VERSION:=0.2.5
$(PKG)_SOURCE:=uClibc++-$($(PKG)_VERSION).tar.bz2
$(PKG)_SOURCE_MD5:=b7b81b8ffa75e6b530b850fddd00e83b
$(PKG)_SITE:=http://git.uclibc.org/uClibc++/snapshot
$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/uClibc++-$($(PKG)_VERSION)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/libuClibc++-$($(PKG)_LIB_VERSION).so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuClibc++-$($(PKG)_LIB_VERSION).so
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libuClibc++-$($(PKG)_LIB_VERSION).so

$(PKG)_STAGING_WRAPPER:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/$(REAL_GNU_TARGET_NAME)-g++-uc

$(PKG)_COMMON_MAKE_OPTS := -C $($(PKG)_DIR)
$(PKG)_COMMON_MAKE_OPTS += CPU_CFLAGS="$(TARGET_CFLAGS)"
$(PKG)_COMMON_MAKE_OPTS += CROSS_COMPILE="$(TARGET_CROSS)"

$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_LFS
$(PKG)_REBUILD_SUBOPTS += FREETZ_LIB_libuClibc__WITH_WCHAR

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	cp $(UCLIBCXX_MAKE_DIR)/Config.uclibc++ $(UCLIBCXX_DIR)/.config
	$(call PKG_EDIT_CONFIG, \
		UCLIBCXX_HAS_LFS=$(FREETZ_TARGET_LFS) \
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
	$(INSTALL_LIBRARY_STRIP_WILDCARD_BEFORE_SO)

uclibcxx: $($(PKG)_STAGING_BINARY) $($(PKG)_STAGING_WRAPPER)

uclibcxx-precompiled: $($(PKG)_TARGET_BINARY)

uclibcxx-clean:
	-$(SUBMAKE) $(UCLIBCXX_COMMON_MAKE_OPTS) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/*-g++-uc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libuClibc++* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/uClibc++

uclibcxx-uninstall:
	$(RM) $(UCLIBCXX_TARGET_DIR)/libuClibc++*.so*

$(PKG_FINISH)
