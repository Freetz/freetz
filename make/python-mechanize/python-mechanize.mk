$(call PKG_INIT_BIN, 0.2.5)
$(PKG)_SOURCE:=mechanize-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=32657f139fc2fb75bcf193b63b8c60b2
$(PKG)_SITE:=https://pypi.python.org/packages/source/m/mechanize

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/mechanize-$($(PKG)_VERSION)

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mechanize/__init__.py

$(PKG)_DEPENDS_ON := python

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_MECHANIZE)
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_MECHANIZE_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_MECHANIZE_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mechanize \
		$(PYTHON_MECHANIZE_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/mechanize-*.egg-info

$(PKG_FINISH)
