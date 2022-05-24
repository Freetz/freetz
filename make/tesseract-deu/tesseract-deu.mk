$(call PKG_INIT_BIN, 3.02)
$(PKG)_SOURCE:=tesseract-ocr-$($(PKG)_VERSION).deu.tar.gz
$(PKG)_HASH:=d03cdd0b00d368ff49ebaf77b8758bcf2ff1b0d39331368987e622ac261443ca
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
