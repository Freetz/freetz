PYTHON_HOST_VERSION:=2.7.18
PYTHON_HOST_SOURCE:=Python-$(PYTHON_HOST_VERSION).tar.xz
PYTHON_HOST_MD5:=fd6cc8ec0a78c44036f825e739f36e5a
PYTHON_HOST_SITE:=http://www.python.org/ftp/python/$(PYTHON_HOST_VERSION)

PYTHON_HOST_DIR:=$(TOOLS_SOURCE_DIR)/Python-$(PYTHON_HOST_VERSION)
PYTHON_HOST_BINARY:=$(PYTHON_HOST_DIR)/python
PYTHON_HOST_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/bin/python2.7


python-host-source: $(DL_DIR)/$(PYTHON_HOST_SOURCE)
$(DL_DIR)/$(PYTHON_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PYTHON_HOST_SOURCE) $(PYTHON_HOST_SITE) $(PYTHON_HOST_MD5)

python-host-unpacked: $(PYTHON_HOST_DIR)/.unpacked
$(PYTHON_HOST_DIR)/.unpacked: $(DL_DIR)/$(PYTHON_HOST_SOURCE) | $(TOOLS_SOURCE_DIR) $(UNPACK_TARBALL_PREREQUISITES)
	$(call UNPACK_TARBALL,$(DL_DIR)/$(PYTHON_HOST_SOURCE),$(TOOLS_SOURCE_DIR))
	@touch $@

# python quirk:
#  CFLAGS and OPT flags passed here are then used while cross-compiling -> use some target neutral flags
python-host-configured: $(PYTHON_HOST_DIR)/.configured
$(PYTHON_HOST_DIR)/.configured: $(PYTHON_HOST_DIR)/.unpacked
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

$(PYTHON_HOST_BINARY): $(PYTHON_HOST_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PYTHON_HOST_DIR) \
		all Parser/pgen \
		$(SILENT)
	@touch -c $@

$(PYTHON_HOST_TARGET_BINARY): $(PYTHON_HOST_BINARY) | $(HOST_TOOLS_DIR)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PYTHON_HOST_DIR) \
		DESTDIR="$(HOST_TOOLS_DIR)" \
		install \
		$(SILENT)
	cp -a $(PYTHON_HOST_BINARY) $(PYTHON_HOST_DIR)/Parser/pgen \
		$(HOST_TOOLS_DIR)/usr/bin

python-host-precompiled: $(PYTHON_HOST_TARGET_BINARY)


python-host-clean:
	-$(MAKE) -C $(PYTHON_HOST_DIR) clean

python-host-dirclean:
	$(RM) -r $(PYTHON_HOST_DIR)

python-host-distclean: python-host-dirclean
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

