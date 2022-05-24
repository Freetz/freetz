$(call TOOLS_INIT, 2.7.18)
$(PKG)_SOURCE:=Python-$($(PKG)_VERSION).tar.xz
$(PKG)_SOURCE_MD5:=fd6cc8ec0a78c44036f825e739f36e5a
$(PKG)_SITE:=http://www.python.org/ftp/python/$($(PKG)_VERSION)

$(PKG)_DIR:=$(TOOLS_SOURCE_DIR)/Python-$($(PKG)_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/python
$(PKG)_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/bin/python2.7


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

# python quirk:
#  CFLAGS and OPT flags passed here are then used while cross-compiling -> use some target neutral flags
$(pkg)-configured: $($(PKG)_DIR)/.configured
$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	(cd $(PYTHON_HOST_DIR); $(RM) config.cache; \
		CC="$(TOOLS_CC)" \
		CXX="$(TOOLS_CXX)" \
		CFLAGS="$(TOOLS_CFLAGS)" \
		LDFLAGS="$(TOOLS_LDFLAGS)" \
		OPT="-fno-inline" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/usr \
		$(SILENT) \
	);
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	(PATH=$(TARGET_PATH); \
		$(TOOLS_SUBMAKE) -C $(PYTHON_HOST_DIR) \
		all Parser/pgen )
	@touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY) | $(HOST_TOOLS_DIR)
	(PATH=$(TARGET_PATH); \
		$(TOOLS_SUBMAKE) -C $(PYTHON_HOST_DIR) \
		DESTDIR="$(HOST_TOOLS_DIR)" \
		install )
	cp -a $(PYTHON_HOST_BINARY) $(PYTHON_HOST_DIR)/Parser/pgen \
		$(HOST_TOOLS_DIR)/usr/bin

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(PYTHON_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(PYTHON_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(PYTHON_HOST_TARGET_BINARY) \
		$(HOST_TOOLS_DIR)/usr/bin/2to3 \
		$(HOST_TOOLS_DIR)/usr/bin/easy_install* \
		$(HOST_TOOLS_DIR)/usr/bin/idle \
		$(HOST_TOOLS_DIR)/usr/bin/pgen \
		$(HOST_TOOLS_DIR)/usr/bin/pydoc \
		$(HOST_TOOLS_DIR)/usr/bin/python* \
		$(HOST_TOOLS_DIR)/usr/bin/smtpd.py \
		$(HOST_TOOLS_DIR)/usr/include/python2.7 \
		$(HOST_TOOLS_DIR)/usr/lib/libpython2.7.* \
		$(HOST_TOOLS_DIR)/usr/lib/python2.7 \
		$(HOST_TOOLS_DIR)/usr/lib/pkgconfig/python* \
		$(HOST_TOOLS_DIR)/usr/share/python2.7 \
		$(HOST_TOOLS_DIR)/usr/share/man/man1/python*

$(TOOLS_FINISH)
