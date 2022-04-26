$(call TOOL_INIT, 2.7.18)
$(TOOL)_SOURCE:=Python-$($(TOOL)_VERSION).tar.xz
$(TOOL)_MD5:=fd6cc8ec0a78c44036f825e739f36e5a
$(TOOL)_SITE:=http://www.python.org/ftp/python/$($(TOOL)_VERSION)

$(TOOL)_DIR:=$(TOOLS_SOURCE_DIR)/Python-$($(TOOL)_VERSION)
$(TOOL)_BINARY:=$($(TOOL)_DIR)/python
$(TOOL)_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/bin/python2.7


$(tool)-source: $(DL_DIR)/$($(TOOL)_SOURCE)
$(DL_DIR)/$($(TOOL)_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PYTHON_HOST_SOURCE) $(PYTHON_HOST_SITE) $(PYTHON_HOST_MD5)

$(tool)-unpacked: $($(TOOL)_DIR)/.unpacked
$($(TOOL)_DIR)/.unpacked: $(DL_DIR)/$($(TOOL)_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(PYTHON_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	@touch $@

# python quirk:
#  CFLAGS and OPT flags passed here are then used while cross-compiling -> use some target neutral flags
$(tool)-configured: $($(TOOL)_DIR)/.configured
$($(TOOL)_DIR)/.configured: $($(TOOL)_DIR)/.unpacked
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

$($(TOOL)_BINARY): $($(TOOL)_DIR)/.configured
	(PATH=$(TARGET_PATH); \
		$(TOOL_SUBMAKE) -C $(PYTHON_HOST_DIR) \
		all Parser/pgen )
	@touch -c $@

$($(TOOL)_TARGET_BINARY): $($(TOOL)_BINARY) | $(HOST_TOOLS_DIR)
	(PATH=$(TARGET_PATH); \
		$(TOOL_SUBMAKE) -C $(PYTHON_HOST_DIR) \
		DESTDIR="$(HOST_TOOLS_DIR)" \
		install )
	cp -a $(PYTHON_HOST_BINARY) $(PYTHON_HOST_DIR)/Parser/pgen \
		$(HOST_TOOLS_DIR)/usr/bin

$(tool)-precompiled: $($(TOOL)_TARGET_BINARY)


$(tool)-clean:
	-$(MAKE) -C $(PYTHON_HOST_DIR) clean

$(tool)-dirclean:
	$(RM) -r $(PYTHON_HOST_DIR)

$(tool)-distclean: $(tool)-dirclean
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

$(TOOL_FINISH)
