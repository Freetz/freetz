$(call PKG_INIT_BIN, 3.02)
$(PKG)_SOURCE:=xpdf-$($(PKG)_VERSION).tar.gz
$(PKG)_SITE:=ftp://ftp.foolabs.com/pub/xpdf/
$(PKG)_SOURCE_MD5:=599dc4cc65a07ee868cf92a667a913d2

XPDF_PDFTOOLS:=pdftops pdftotext pdfinfo pdffonts pdfimages
XPDF_PROGRAMS:=$(foreach target,$(XPDF_PDFTOOLS),\
	$(if $(filter y,$(FREETZ_XPDF_$(target))),$(target)))

XPDF_BINARIES:=$(addprefix $(XPDF_DIR)/xpdf/,$(XPDF_PROGRAMS))
XPDF_TARGET_BINARIES:=$(addprefix $(XPDF_DEST_DIR)/usr/bin/,$(XPDF_PROGRAMS))
XPDF_TARGET_LIBS:=$(XPDF_DEST_DIR)/usr/lib/libxpdf.so.1

$(PKG)_DEPENDS_ON := uclibcxx

$(PKG)_CONFIGURE_OPTIONS += --enable-a4-paper --without-freetype2-library \
	--without-t1-library --without-libpaper-library --without-x

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)
		
$(XPDF_BINARIES): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -j 1 -C $(XPDF_DIR) $(XPDF_PROGRAMS)
# -j 1 because my ad-hoc 'shared' patch does not specify all depencies properly

$(XPDF_TARGET_BINARIES): $(XPDF_DEST_DIR)/usr/bin/%: $(XPDF_DIR)/xpdf/%
	$(INSTALL_BINARY_STRIP)

$(XPDF_TARGET_LIBS): $(XPDF_DEST_DIR)/usr/lib/%: $(XPDF_DIR)/xpdf/% $(XPDF_TARGET_BINARIES)
	$(INSTALL_BINARY_STRIP)

$(pkg): 

$(pkg)-precompiled: $(XPDF_TARGET_BINARIES) $(XPDF_TARGET_LIBS)

$(pkg)-clean:
	-$(SUBMAKE) -C $(XPDF_DIR) clean

$(pkg)-uninstall:
	$(RM) $(XPDF_TARGET_BINARIES) $(XPDF_TARGET_LIBS)

$(PKG_FINISH)
