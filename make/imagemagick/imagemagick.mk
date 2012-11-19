$(call PKG_INIT_BIN, 6.8.0-4)
$(PKG)_SOURCE:=ImageMagick-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=e2bb7748448ab288841df6b42bdd03bf
$(PKG)_SITE:=http://www.$(pkg).org/download
$(PKG)_DIR:=$(SOURCE_DIR)/ImageMagick-$($(PKG)_VERSION)

$(PKG)_BINARIES_ALL:=convert mogrify stream montage import identify \
  display conjure compare animate composite
$(PKG)_BINARIES := $(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_BINARIES_ALL))
$(PKG)_BINARIES_TARGET_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DEST_DIR)/usr/bin/%)

ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC)),y)
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/utilities/%)
else
$(PKG)_BINARIES_BUILD_DIR:=$($(PKG)_BINARIES:%=$($(PKG)_DIR)/utilities/.libs/%)
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_freetype
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_ghostscript_fonts
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_jpeg
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_libz
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_png
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_xml
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_IMAGEMAGICK_STATIC

$(PKG)_LIB_CORE:=libMagickCore.so.6.0.0
$(PKG)_LIB_CORE_BUILD_DIR:=$($(PKG)_LIB_CORE:%=$($(PKG)_DIR)/magick/.libs/%)
$(PKG)_LIB_CORE_TARGET_DIR:=$($(PKG)_LIB_CORE:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_LIB_WAND:=libMagickWand.so.6.0.0
$(PKG)_LIB_WAND_BUILD_DIR:=$($(PKG)_LIB_WAND:%=$($(PKG)_DIR)/wand/.libs/%)
$(PKG)_LIB_WAND_TARGET_DIR:=$($(PKG)_LIB_WAND:%=$($(PKG)_DEST_LIBDIR)/%)

$(PKG)_XML_CONFIG_FILES:= coder.xml colors.xml delegates.xml log.xml magic.xml mime.xml policy.xml \
			 thresholds.xml type.xml type-dejavu.xml type-ghostscript.xml type-windows.xml

$(PKG)_XML_CONFIG_DIR:= $($(PKG)_XML_CONFIG_FILES:%=$($(PKG)_DIR)/config/%)

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_DEPENDS_ON :=    
ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_freetype)),y)
$(PKG)_DEPENDS_ON += freetype
endif
ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_ghostscript_fonts)),y)
$(PKG)_DEPENDS_ON += ghostscript-fonts
endif
ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_jpeg)),y)
$(PKG)_DEPENDS_ON += jpeg
endif
ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_libz)),y)
$(PKG)_DEPENDS_ON += zlib
endif
ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_png)),y)
$(PKG)_DEPENDS_ON += libpng
endif
ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_xml)),y)
$(PKG)_DEPENDS_ON += libxml2
endif

$(PKG)_CONFIGURE_OPTIONS := --with-gs-font-dir=/usr/share/ghostscript/fonts
$(PKG)_CONFIGURE_OPTIONS += --with-magick-plus-plus=no
$(PKG)_CONFIGURE_OPTIONS += --with-x=no

$(PKG)_CONFIGURE_OPTIONS += --enable-static=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),yes,no) 
$(PKG)_CONFIGURE_OPTIONS += --enable-shared=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),no,yes) 

$(PKG)_CONFIGURE_OPTIONS += --with-zlib=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_libz),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-jpeg=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_jpeg),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-png=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_png),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-xml=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_xml),yes,no)
$(PKG)_CONFIGURE_OPTIONS += --with-freetype=$(if $(FREETZ_PACKAGE_IMAGEMAGICK_freetype),yes,no)

       
$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR) $($(PKG)_LIB_CORE_BUILD_DIR) $($(PKG)_LIB_WAND_BUILD_DIR): $($(PKG)_DIR)/.configured	
	$(SUBMAKE) -C $(IMAGEMAGICK_DIR)
	if [ "$FREETZ_PACKAGE_IMAGEMAGICK_xml" == "y" ]; then \
		mkdir -p $(IMAGEMAGICK_DEST_DIR)/etc/ImageMagick; \
		cp $(IMAGEMAGICK_XML_CONFIG_DIR) $(IMAGEMAGICK_DEST_DIR)/etc/ImageMagick; \
	fi;

ifeq ($(strip $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC)),y)
$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/utilities/%
	$(INSTALL_BINARY_STRIP)
else
$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_DEST_DIR)/usr/bin/%: $($(PKG)_DIR)/utilities/.libs/%
	$(INSTALL_BINARY_STRIP)
$($(PKG)_LIB_CORE_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/magick/.libs/%
	$(INSTALL_LIBRARY_STRIP)
$($(PKG)_LIB_WAND_TARGET_DIR): $($(PKG)_DEST_LIBDIR)/%: $($(PKG)_DIR)/wand/.libs/%
	$(INSTALL_LIBRARY_STRIP)
endif

$(pkg):

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR) \
  $(if $(FREETZ_PACKAGE_IMAGEMAGICK_STATIC),,$($(PKG)_LIB_CORE_TARGET_DIR) $($(PKG)_LIB_WAND_TARGET_DIR))

$(pkg)-clean:
	-$(SUBMAKE) -C $(IMAGEMAGICK_DIR) clean
	$(RM) $(IMAGEMAGICK_DIR)/.configured

$(pkg)-uninstall:
	$(RM) \
	  $(IMAGEMAGICK_BINARIES_TARGET_DIR) \
	  $(IMAGEMAGICK_LIB_CORE_TARGET_DIR) \
	  $(IMAGEMAGICK_LIB_WAND_TARGET_DIR)

$(PKG_FINISH)
