$(call PKG_INIT_BIN, 0.1.0)
$(PKG)_SOURCE:=PyRRD-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=c33a0760b42a23e45e423b8b9f2cd0b0
$(PKG)_SITE:=https://pyrrd.googlecode.com/files

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/PyRRD-$($(PKG)_VERSION)

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
