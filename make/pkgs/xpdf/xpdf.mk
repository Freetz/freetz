$(call PKG_INIT_BIN, 3.04)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=11390c74733abcb262aaca4db68710f13ffffd42bfe2a0861a5dfc912b2977e5
$(PKG)_SITE:=ftp://ftp.foolabs.com/pub/$(pkg)

$(PKG)_BINARIES_ALL := pdftops pdftotext pdfinfo pdffonts pdfimages
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/xpdf/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/bin/,$($(PKG)_BINARIES))

$(PKG)_LIBS_BUILD_DIR := $($(PKG)_DIR)/xpdf/libxpdf.so.1
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_DEST_LIBDIR)/libxpdf.so.1
$(PKG)_EXCLUDED += $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON += $(STDCXXLIB)
$(PKG)_REBUILD_SUBOPTS += FREETZ_STDCXXLIB
$(PKG)_REBUILD_SUBOPTS += $($(PKG)_BINARIES_ALL:%=FREETZ_PACKAGE_XPDF_%)

$(PKG)_CONFIGURE_OPTIONS += \
	--enable-a4-paper \
	--without-freetype2-library \
	--without-t1-library \
	--without-libpaper-library \
	--without-x

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE1) -C $(XPDF_DIR) $(XPDF_BINARIES) LIBXPDF_BINS="$(XPDF_BINARIES)"

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/xpdf/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/xpdf/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(SUBMAKE) -C $(XPDF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(XPDF_BINARIES_ALL:%=$(XPDF_DEST_DIR)/usr/bin/%) $(XPDF_DEST_LIBDIR)/libxpdf*

$(PKG_FINISH)
