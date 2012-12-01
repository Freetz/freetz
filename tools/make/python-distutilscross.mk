PYTHON_DISTUTILSCROSS_VERSION:=0.1
PYTHON_DISTUTILSCROSS_SOURCE:=distutilscross-$(PYTHON_DISTUTILSCROSS_VERSION).tar.gz
PYTHON_DISTUTILSCROSS_MD5:=700801380a336a01925ad8409ad98c25
PYTHON_DISTUTILSCROSS_SITE:=http://pypi.python.org/packages/source/d/distutilscross

PYTHON_DISTUTILSCROSS_DIR:=$(TOOLS_SOURCE_DIR)/distutilscross-$(PYTHON_DISTUTILSCROSS_VERSION)
PYTHON_DISTUTILSCROSS_BINARY:=$(TOOLS_SOURCE_DIR)/distutilscross-$(PYTHON_DISTUTILSCROSS_VERSION)/distutilscross/crosscompile.py
PYTHON_DISTUTILSCROSS_TARGET_BINARY:=$(HOST_TOOLS_DIR)/usr/lib/python2.7/site-packages/distutilscross-$(PYTHON_DISTUTILSCROSS_VERSION)-py2.7.egg

python-distutilscross-source: $(DL_DIR)/$(PYTHON_DISTUTILSCROSS_SOURCE)
$(DL_DIR)/$(PYTHON_DISTUTILSCROSS_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PYTHON_DISTUTILSCROSS_SOURCE) $(PYTHON_DISTUTILSCROSS_SITE) $(PYTHON_DISTUTILSCROSS_MD5)

python-distutilscross-unpacked: $(PYTHON_DISTUTILSCROSS_DIR)/.unpacked
$(PYTHON_DISTUTILSCROSS_DIR)/.unpacked: $(DL_DIR)/$(PYTHON_DISTUTILSCROSS_SOURCE) | $(TOOLS_SOURCE_DIR)
	tar -C $(TOOLS_SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(PYTHON_DISTUTILSCROSS_SOURCE)
	@touch $@

python-distutilscross-configured: $(PYTHON_DISTUTILSCROSS_DIR)/.configured
$(PYTHON_DISTUTILSCROSS_DIR)/.configured: $(PYTHON_DISTUTILSCROSS_DIR)/.unpacked
	@touch $@

$(PYTHON_DISTUTILSCROSS_BINARY): $(PYTHON_DISTUTILSCROSS_DIR)/.configured
	(cd $(PYTHON_DISTUTILSCROSS_DIR); \
		$(INVOKE_HOST_PYTHON) setup.py build; \
	)
	@touch -c $@

$(PYTHON_DISTUTILSCROSS_TARGET_BINARY): $(PYTHON_DISTUTILSCROSS_BINARY)
	(cd $(PYTHON_DISTUTILSCROSS_DIR); \
		$(INVOKE_HOST_PYTHON) setup.py install; \
	)

python-distutilscross: $(PYTHON_DISTUTILSCROSS_TARGET_BINARY) | python-host python-setuptools

python-distutilscross-clean:
	(cd $(PYTHON_DISTUTILSCROSS_DIR); \
		$(INVOKE_HOST_PYTHON) setup.py clean; \
	)

python-distutilscross-dirclean:
	$(RM) -r \
		$(PYTHON_DISTUTILSCROSS_DIR) \
		$(PYTHON_DISTUTILSCROSS_TARGET_BINARY) \
		$(HOST_TOOLS_DIR)/usr/lib/python2.7/site-packages/distutilscross*

.PHONY: python-distutilscross-source python-distutilscross-unpacked python-distutilscross-configured python-distutilscross python-distutilscross-clean python-distutilscross-dirclean
