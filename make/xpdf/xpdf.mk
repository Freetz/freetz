$(call PKG_INIT_BIN, 3.02)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=599dc4cc65a07ee868cf92a667a913d2
$(PKG)_SITE:=ftp://ftp.foolabs.com/pub/xpdf/

$(PKG)_BINARIES_ALL := pdftops pdftotext pdfinfo pdffonts pdfimages
$(PKG)_BINARIES := $(foreach binary,$($(PKG)_BINARIES_ALL),$(if $(FREETZ_$(PKG)_$(binary)),$(binary)))
$(PKG)_BINARIES_BUILD_DIR := $(addprefix $($(PKG)_DIR)/xpdf/,$($(PKG)_BINARIES))
$(PKG)_BINARIES_TARGET_DIR := $(addprefix $($(PKG)_DEST_DIR)/usr/bin/,$($(PKG)_BINARIES))
$(PKG)_LIBS_BUILD_DIR := $($(PKG)_DIR)/xpdf/libxpdf.so.1
$(PKG)_LIBS_TARGET_DIR := $($(PKG)_DEST_DIR)/usr/lib/libxpdf.so.1
$(PKG)_NOT_INCLUDED := $(patsubst %,$($(PKG)_DEST_DIR)/usr/bin/%,$(filter-out $($(PKG)_BINARIES),$($(PKG)_BINARIES_ALL)))

$(PKG)_DEPENDS_ON := uclibcxx

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
	PATH="$(TARGET_PATH)" \
		$(MAKE) -j 1 -C $(XPDF_DIR) $(XPDF_PROGRAMS)
# -j 1 because my ad-hoc 'shared' patch does not specify all depencies properly

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/xpdf/%
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/lib/%: $($(PKG)_DIR)/xpdf/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) $($(PKG)_LIBS_TARGET_DIR)

$(pkg)-clean:
	-$(MAKE) -C $(XPDF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(XPDF_BINARIES_ALL:%=$(XPDF_DEST_DIR)/usr/bin/%) $(XPDF_DEST_DIR)/usr/lib/libxpdf*

$(PKG_FINISH)
