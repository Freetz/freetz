$(call PKG_INIT_BIN,1.0.27)
$(PKG)_LIB_VERSION:=1.0.27
$(PKG)_SOURCE:=$(pkg)_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_HASH:=293747bf37275c424ebb2c833f8588601a60b2f9653945d5a3194875355e36c9
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/s/$(pkg)

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
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_DEST_LIBDIR)/libsane.so.$($(PKG)_LIB_VERSION)

$(PKG)_TARGET_BINARIES:=$($(PKG)_TARGET_saned)
ifeq ($(strip $(FREETZ_PACKAGE_SANE_BACKENDS_sane_find_scanner)),y)
$(PKG)_TARGET_BINARIES+=$($(PKG)_TARGET_sane_find_scanner)
endif
ifeq ($(strip $(FREETZ_PACKAGE_SANE_BACKENDS_scanimage)),y)
$(PKG)_TARGET_BINARIES+=$($(PKG)_TARGET_scanimage)
endif

$(PKG)_CATEGORY:=Unstable

$(PKG)_DEPENDS_ON+= libusb1
ifeq ($(strip $(FREETZ_PACKAGE_SANE_BACKENDS_WITH_AVAHI)),y)
$(PKG)_DEPENDS_ON += avahi
endif

# include selected backends
include $($(PKG)_MAKE_DIR)/sane-backends.in

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_SANE_BACKENDS_WITH_AVAHI
$(PKG)_REBUILD_SUBOPTS += FREETZ_TARGET_IPV6_SUPPORT

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_SANE_BACKENDS_WITH_AVAHI),--enable-avahi,--disable-avahi)
$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_TARGET_IPV6_SUPPORT),--enable-ipv6,--disable-ipv6)
$(PKG)_CONFIGURE_OPTIONS += --enable-pthread
$(PKG)_CONFIGURE_OPTIONS += --disable-latex
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-translations
$(PKG)_CONFIGURE_OPTIONS += --without-gphoto2
$(PKG)_CONFIGURE_OPTIONS += --with-usb

$(PKG)_CONFIGURE_ENV+=BACKENDS="$(SANE_BACKENDS)"

$(call REPLACE_LIBTOOL)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_saned) $($(PKG)_sane_find_scanner) $($(PKG)_scanimage) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SANE_BACKENDS_DIR)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(SANE_BACKENDS_DIR)/include \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(SUBMAKE) -C $(SANE_BACKENDS_DIR)/backend \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-libLTLIBRARIES
	$(SUBMAKE) -C $(SANE_BACKENDS_DIR)/tools \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-pkgconfigDATA
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sane-backends.pc

$($(PKG)_TARGET_saned): $($(PKG)_saned)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_sane_find_scanner): $($(PKG)_sane_find_scanner)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_TARGET_scanimage): $($(PKG)_scanimage)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(PKG)_LIB_TARGET_BACKENDS_BINARIES:
	mkdir -p $(SANE_BACKENDS_DEST_LIBDIR)/sane
	for backend in $(SANE_BACKENDS); do \
		cp -a $(SANE_BACKENDS_DIR)/backend/.libs/libsane-$${backend}.so* $(SANE_BACKENDS_DEST_LIBDIR)/sane; \
	done
	$(TARGET_STRIP) $(SANE_BACKENDS_DEST_LIBDIR)/sane/*
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
	-$(SUBMAKE) -C $(SANE_BACKENDS_DIR) clean
	$(RM) -r $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libsane* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/sane-backends.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/sane

$(pkg)-uninstall:
	$(RM) -r $(SANE_BACKENDS_TARGET_saned) \
		$(SANE_BACKENDS_TARGET_sane_find_scanner) \
		$(SANE_BACKENDS_TARGET_scanimage) \
		$(SANE_BACKENDS_LIB_TARGET_BACKENDS_BINARIES)

$(pkg)-config-update: $($(PKG)_DIR)/.unpacked
	$(SANE_BACKENDS_MAKE_DIR)/config-update.pl \
		$(SANE_BACKENDS_VERSION) \
		$(SANE_BACKENDS_DIR)/configure \
		$(SANE_BACKENDS_MAKE_DIR)/Config.in \
		$(SANE_BACKENDS_MAKE_DIR)/sane-backends.in \
		$(SANE_BACKENDS_MAKE_DIR)/external.in \
		$(SANE_BACKENDS_MAKE_DIR)/external.files
.PHONY: $(pkg)-config-update

$(PKG_FINISH)
