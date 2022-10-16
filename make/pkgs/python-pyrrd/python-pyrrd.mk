$(call PKG_INIT_BIN, 0.1.0)
$(PKG)_SOURCE:=PyRRD-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=103b3a6f855e38946e0fc100a54ec46be69c37cc349ceb95decad35424f629a9
$(PKG)_SITE:=https://pyrrd.googlecode.com/files

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd/__init__.py

$(PKG)_DEPENDS_ON += python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYRRD)
	(cd $(dir $@); $(RM) -r backend/tests testing tests)
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_PYRRD_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyrrd \
		$(PYTHON_PYRRD_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/PyRRD-*.egg-info

$(PKG_FINISH)
