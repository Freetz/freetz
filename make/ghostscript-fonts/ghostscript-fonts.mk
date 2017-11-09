$(call PKG_INIT_BIN, 8.11)
$(PKG)_SOURCE:=ghostscript-fonts-std-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=6865682b095f8c4500c54b285ff05ef6
$(PKG)_SITE:=@SF/gs-fonts

$(PKG)_RUNTIME_DIR:=/usr/share/fonts/gs-fonts

$(PKG)_MARKER_FILE:=a010013l.afm
$(PKG)_MARKER_TARGET_DIR:=$($(PKG)_DEST_DIR)/$($(PKG)_RUNTIME_DIR)/$($(PKG)_MARKER_FILE)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_MARKER_TARGET_DIR): $($(PKG)_DIR)/.configured
	@srcdir="$(dir $<)"; \
	destdir="$(dir $@)"; \
	mkdir -p $$destdir; \
	cp $$srcdir/*.afm $$srcdir/*.pfb $$destdir/; \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_MARKER_TARGET_DIR)

$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) -r $(GHOSTSCRIPT_FONTS_DEST_DIR)/$(GHOSTSCRIPT_FONTS_RUNTIME_DIR)

$(PKG_FINISH)
