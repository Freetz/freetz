$(call PKG_INIT_BIN, 7.19.5)
$(PKG)_SOURCE:=pycurl-$($(PKG)_VERSION).tar.gz
$(PKG)_SOURCE_MD5:=47b4eac84118e2606658122104e62072
$(PKG)_SITE:=http://pycurl.sourceforge.net/download

$(PKG)_DIR:=$($(PKG)_SOURCE_DIR)/pycurl-$($(PKG)_VERSION)

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/pycurl.so

$(PKG)_DEPENDS_ON += python curl

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC
$(PKG)_REBUILD_SUBOPTS += $(filter FREETZ_LIB_libcurl%,$(CURL_REBUILD_SUBOPTS))

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_PYCURL, --curl-config=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/curl-config)

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
