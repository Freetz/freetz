$(call PKG_INIT_BIN,1.0.19)
$(PKG)_LIB_VERSION:=1.0.19
$(PKG)_SOURCE:=sane-backends-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp2.sane-project.org/pub/sane/sane-backends-1.0.19

# saned
$(PKG)_TARGET_saned:=$($(PKG)_DEST_DIR)/usr/sbin/saned
$(PKG)_saned:=$($(PKG)_DIR)/frontend/.libs/saned

# sane-find-scanner
$(PKG)_TARGET_sane_find_scanner:=$($(PKG)_DEST_DIR)/usr/bin/sane-find-scanner
$(PKG)_sane_find_scanner:=$($(PKG)_DIR)/tools/sane-find-scanner

# scanimage
$(PKG)_TARGET_scanimage:=$($(PKG)_DEST_DIR)/usr/bin/scanimage
$(PKG)_scanimage:=$($(PKG)_DIR)/frontend/.libs/scanimage

# libsane
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/backend/.libs/libsane.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane.so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_TARGET_BINARY:=root/usr/lib/libsane.so.$($(PKG)_LIB_VERSION)

$(PKG)_TARGET_BINARIES:=$($(PKG)_TARGET_saned)
ifeq ($(strip $(FREETZ_SANE_sane_find_scanner)),y)
$(PKG)_TARGET_BINARIES+=$($(PKG)_TARGET_sane_find_scanner)
endif
ifeq ($(strip $(FREETZ_SANE_scanimage)),y)
$(PKG)_TARGET_BINARIES+=$($(PKG)_TARGET_scanimage)
endif

$(PKG)_DEPENDS_ON:= libusb
ifeq ($(strip $(FREETZ_SANE_BACKEND_dc210)),y)
$(PKG)_DEPENDS_ON+= jpeg
endif
ifeq ($(strip $(FREETZ_SANE_BACKEND_dc240)),y)
$(PKG)_DEPENDS_ON+= jpeg
endif

# include selected backends
include $($(PKG)_MAKE_DIR)/sane-backends.in

$(PKG)_CONFIGURE_OPTIONS += --disable-ipv6
$(PKG)_CONFIGURE_OPTIONS += --disable-translations
$(PKG)_CONFIGURE_OPTIONS += --without-gphoto2
$(PKG)_CONFIGURE_OPTIONS += --disable-debug
$(PKG)_CONFIGURE_OPTIONS += --disable-fork-process

$(PKG)_CONFIGURE_ENV+=BACKENDS="$(SANE_BACKENDS)"
$(PKG)_CONFIGURE_ENV+=SANEI_JPEG="$(SANEI_JPEG)"
$(PKG)_CONFIGURE_ENV+=SANEI_JPEG_LO="$(SANEI_JPEG_LO)"


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_saned) $($(PKG)_sane_find_scanner) $($(PKG)_scanimage) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	PATH="$(TARGET_PATH)" \
		$(MAKE1) -C $(SANE_BACKENDS_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	PATH=$(TARGET_TOOLCHAIN_PATH) \
		$(MAKE) -C $(SANE_BACKENDS_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		freetz-install-devel
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libsane.la

$($(PKG)_TARGET_saned): $($(PKG)_saned)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_sane_find_scanner): $($(PKG)_sane_find_scanner)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_scanimage): $($(PKG)_scanimage)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	mkdir -p $(dir $@)
	cp -a $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane*.so* root/usr/lib
	$(TARGET_STRIP) $@

$(PKG)_LIB_TARGET_BACKENDS_BINARIES:
	mkdir -p $(SANE_BACKENDS_DEST_DIR)/usr/lib/sane
	for backend in $(SANE_BACKENDS); do \
		cp -a $(SANE_BACKENDS_DIR)/backend/.libs/libsane-$${backend}.so* $(SANE_BACKENDS_DEST_DIR)/usr/lib/sane; \
	done
	$(TARGET_STRIP) $(SANE_BACKENDS_DEST_DIR)/usr/lib/sane/*
.PHONY: $(PKG)_LIB_TARGET_BACKENDS_BINARIES

$(PKG)_TARGET_CONF:
	mkdir -p $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends
	$(RM) $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends/saned.conf
	$(RM) $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends/dll.conf
	for backend in $(SANE_BACKENDS); do \
		if [ "$$backend" != "dll" ]; then \
			if [ -e $(SANE_BACKENDS_DIR)/backend/$${backend}.conf ]; then \
				cp $(SANE_BACKENDS_DIR)/backend/$${backend}.conf $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends; \
			fi; \
			echo $$backend >> $(SANE_BACKENDS_DEST_DIR)/etc/default.sane-backends/dll.conf; \
		fi; \
	done
.PHONY: $(PKG)_TARGET_CONF

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARIES) $($(PKG)_LIB_TARGET_BINARY) $(PKG)_LIB_TARGET_BACKENDS_BINARIES $(PKG)_TARGET_CONF

$(pkg)-clean:
	-$(MAKE) -C $(SANE_BACKENDS_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sane

$(pkg)-uninstall:
	$(RM) -r $(SANE_BACKENDS_TARGET_saned) \
		$(SANE_BACKENDS_TARGET_sane_find_scanner) \
		$(SANE_BACKENDS_TARGET_scanimage) \
		$(SANE_BACKENDS_LIB_TARGET_BACKENDS_BINARIES)

$(PKG_FINISH)
