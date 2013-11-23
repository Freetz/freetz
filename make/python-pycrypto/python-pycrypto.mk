$(call PKG_INIT_BIN, 2.6.1)
$(PKG)_SOURCE:=pycrypto-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=55a61a054aa66812daf5161a0d5d7eda
$(PKG)_SITE:=http://ftp.dlitz.net/pub/dlitz/crypto/pycrypto

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/pycrypto-$($(PKG)_VERSION)

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto/PublicKey/_fastmath.so

$(PKG)_DEPENDS_ON := python gmp

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYCRYPTO, , TARGET_ARCH=$(FREETZ_TARGET_ARCH))

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) -r $(PYTHON_PYCRYPTO_DIR)/build

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/Crypto \
		$(PYTHON_PYCRYPTO_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycrypto-*.egg-info

$(PKG_FINISH)
