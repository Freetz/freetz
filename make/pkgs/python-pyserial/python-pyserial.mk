$(call PKG_INIT_BIN, 2.6)
$(PKG)_SOURCE:=pyserial-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=049dbcda0cd475d3be903e721d60889ee2cc4ec3b62892a81ecef144196413ed
$(PKG)_SITE:=https://pypi.python.org/packages/source/p/pyserial

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/serial/__init__.py

$(PKG)_DEPENDS_ON += python

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYSERIAL)
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_PYSERIAL_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYSERIAL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/serial \
		$(PYTHON_PYSERIAL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyserial-*.egg-info

$(PKG_FINISH)
