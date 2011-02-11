$(call PKG_INIT_LIB, 0.2.2, uclibcxx)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=uClibc++-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=http://cxx.uclibc.org/src/
$(PKG)_DIR:=$(SOURCE_DIR)/uClibc++-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/libuClibc++-$($(PKG)_LIB_VERSION).so
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++-$($(PKG)_LIB_VERSION).so
$(PKG)_TARGET_DIR:=root/lib
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libuClibc++-$($(PKG)_LIB_VERSION).so

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	cp $(UCLIBCXX_MAKE_DIR)/Config.uclibc++ $(UCLIBCXX_DIR)/.config
	$(call PKG_EDIT_CONFIG, UCLIBCXX_HAS_LFS=$(FREETZ_TARGET_LFS)) $(UCLIBCXX_DIR)/.config
	touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(UCLIBCXX_DIR) \
		ARCH_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) $(MAKE) \
		-C $(UCLIBCXX_DIR) \
		ARCH_CFLAGS="$(TARGET_CFLAGS)" \
		CROSS="$(TARGET_CROSS)" \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	mv $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/g++-uc \
	   $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-g++-uc
	ln -sf $(REAL_GNU_TARGET_NAME)-g++-uc $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-g++-uc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++*.so* $(UCLIBCXX_TARGET_DIR)/
	$(TARGET_STRIP) $@

uclibcxx: $($(PKG)_STAGING_BINARY)

uclibcxx-precompiled: $($(PKG)_TARGET_BINARY)

uclibcxx-clean:
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(GNU_TARGET_NAME)-g++-uc
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/bin/$(REAL_GNU_TARGET_NAME)-g++-uc
	-$(MAKE) -C $(UCLIBCXX_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libuClibc++* 

uclibcxx-uninstall:
	$(RM) $(UCLIBCXX_TARGET_DIR)/libuClibc++*.so*

$(PKG_FINISH)