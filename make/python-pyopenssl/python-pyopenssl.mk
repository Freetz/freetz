$(call PKG_INIT_BIN, 0.13)
$(PKG)_SOURCE:=pyopenssl_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_SOURCE_MD5:=767bca18a71178ca353dff9e10941929
$(PKG)_SITE:=http://ftp.de.debian.org/debian/pool/main/p/pyopenssl

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/pyOpenSSL-$($(PKG)_VERSION)

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/OpenSSL/SSL.so

$(PKG)_DEPENDS_ON := python openssl

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC
$(PKG)_REBUILD_SUBOPTS += $(OPENSSL_REBUILD_SUBOPTS)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYOPENSSL)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_PYOPENSSL_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYOPENSSL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/OpenSSL \
		$(PYTHON_PYOPENSSL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pyOpenSSL-*.egg-info

$(PKG_FINISH)
