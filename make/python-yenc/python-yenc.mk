$(call PKG_INIT_BIN, 0.4.0)
$(PKG)_SOURCE:=yenc-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=075f6c4e4f43b7c6dafac579eabb17287b62d80e9147cbea0b046bc3ee8edd2f
$(PKG)_SITE:=http://www.golug.it/pub/yenc

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_yenc.so

$(PKG)_DEPENDS_ON += python

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_YENC)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_YENC_DIR)/build

$(pkg)-uninstall:
	$(RM) \
		$(PYTHON_YENC_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/yenc.py
		$(PYTHON_YENC_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/_yenc.so
		$(PYTHON_YENC_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/yenc-*.egg-info

$(PKG_FINISH)
