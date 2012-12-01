PYTHON_SETUPTOOLS_VERSION:=0.6c11
PYTHON_SETUPTOOLS_SOURCE:=setuptools-$(PYTHON_SETUPTOOLS_VERSION).tar.gz
PYTHON_SETUPTOOLS_MD5:=7df2a529a074f613b509fb44feefe74e
PYTHON_SETUPTOOLS_SITE:=http://pypi.python.org/packages/source/s/setuptools

PYTHON_SETUPTOOLS_DIR:=$(TOOLS_SOURCE_DIR)/setuptools-$(PYTHON_SETUPTOOLS_VERSION)
PYTHON_SETUPTOOLS_BINARY:=$(TOOLS_SOURCE_DIR)/setuptools-$(PYTHON_SETUPTOOLS_VERSION)/setuptools/__init__.py
PYTHON_SETUPTOOLS_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/lib/python2.7/site-packages/setuptools-$(PYTHON_SETUPTOOLS_VERSION)-py2.7.egg

python-setuptools-source: $(DL_DIR)/$(PYTHON_SETUPTOOLS_SOURCE)
$(DL_DIR)/$(PYTHON_SETUPTOOLS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PYTHON_SETUPTOOLS_SOURCE) $(PYTHON_SETUPTOOLS_SITE) $(PYTHON_SETUPTOOLS_MD5)

python-setuptools-unpacked: $(PYTHON_SETUPTOOLS_DIR)/.unpacked
$(PYTHON_SETUPTOOLS_DIR)/.unpacked: $(DL_DIR)/$(PYTHON_SETUPTOOLS_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(PYTHON_SETUPTOOLS_SOURCE)
	@touch $@

python-setuptools-configured: $(PYTHON_SETUPTOOLS_DIR)/.configured
$(PYTHON_SETUPTOOLS_DIR)/.configured: $(PYTHON_SETUPTOOLS_DIR)/.unpacked
	@touch $@

$(PYTHON_SETUPTOOLS_BINARY): $(PYTHON_SETUPTOOLS_DIR)/.configured
	(cd $(PYTHON_SETUPTOOLS_DIR); \
		$(INVOKE_HOST_PYTHON) setup.py build; \
	)
	@touch -c $@

$(PYTHON_SETUPTOOLS_TARGET_BINARY): $(PYTHON_SETUPTOOLS_BINARY)
	(cd $(PYTHON_SETUPTOOLS_DIR); \
		$(INVOKE_HOST_PYTHON) setup.py install; \
	)

python-setuptools: $(PYTHON_SETUPTOOLS_TARGET_BINARY) | python-host

python-setuptools-clean:
	(cd $(PYTHON_SETUPTOOLS_DIR); \
		$(INVOKE_HOST_PYTHON) setup.py clean; \
	)

python-setuptools-dirclean:
	$(RM) -r \
		$(PYTHON_SETUPTOOLS_DIR) \
		$(PYTHON_SETUPTOOLS_TARGET_BINARY) \
		$(HOST_TOOLS_DIR)/usr/lib/python2.7/site-packages/setuptools*

.PHONY: python-setuptools-source python-setuptools-unpacked python-setuptools-configured python-setuptools python-setuptools-clean python-setuptools-dirclean
