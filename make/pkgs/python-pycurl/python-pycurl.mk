$(call PKG_INIT_BIN, 7.43.0)
$(PKG)_SOURCE:=pycurl-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=aa975c19b79b6aa6c0518c0cc2ae33528900478f0b500531dbcdbf05beec584c
$(PKG)_SITE:=https://pypi.python.org/packages/source/p/pycurl

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl.so

$(PKG)_DEPENDS_ON += python curl

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC
$(PKG)_REBUILD_SUBOPTS += $(CURL_REBUILD_SUBOPTS)

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYCURL, --curl-config=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl-config $(if $(FREETZ_LIB_libcurl_WITH_OPENSSL),--with-ssl))

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON_PYCURL_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_PYCURL_TARGET_BINARY) \
		$(PYTHON_PYCURL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl-*.egg-info \
		$(PYTHON_PYCURL_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/curl

$(PKG_FINISH)
