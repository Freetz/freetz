$(call PKG_INIT_BIN, 2.4.4)
$(PKG)_SOURCE:=Cheetah-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=be308229f0c1e5e5af4f27d7ee06d90bb19e6af3059794e5fd536a6f29a9b550
$(PKG)_SITE:=https://pypi.python.org/packages/source/C/Cheetah

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah/_namemapper.so

$(PKG)_DEPENDS_ON += python

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_CHEETAH, , CHEETAH_INSTALL_WITHOUT_SETUPTOOLS="")

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_CHEETAH_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_CHEETAH_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah \
		$(PYTHON_CHEETAH_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Cheetah-*.egg-info

$(PKG_FINISH)
