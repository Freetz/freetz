$(call PKG_INIT_BIN, 3.02)
$(PKG)_SOURCE:=tesseract-ocr-$($(PKG)_VERSION).eng.tar.gz
$(PKG)_HASH:=c110029560e7f6d41cb852ca23b66899daa4456d9afeeae9d062204bd271bdf8
$(PKG)_SITE:=http://tesseract-ocr.googlecode.com/files

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/share/tessdata/eng.traineddata

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	@mkdir -p $(dir $@); \
	cp $(TESSERACT_ENG_DIR)/tessdata/eng.* $(dir $@); \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) -r $(dir $(TESSERACT_ENG_TARGET_BINARY))

$(PKG_FINISH)
