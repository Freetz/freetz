$(call PKG_INIT_BIN, 3.02)
$(PKG)_SOURCE:=tesseract-ocr-$($(PKG)_VERSION).deu.tar.gz
$(PKG)_SOURCE_MD5:=57bdb26ec7c767e126ff97776d8bfb10
$(PKG)_SITE:=http://tesseract-ocr.googlecode.com/files

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/share/tessdata/deu.traineddata

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@mkdir -p $(dir $@); \
	cp $(TESSERACT_DEU_DIR)/tessdata/deu.* $(dir $@); \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) -r $(dir $(TESSERACT_DEU_TARGET_BINARY))

$(PKG_FINISH)
