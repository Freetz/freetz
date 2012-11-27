PYTHON_HOST_VERSION:=2.7.3
PYTHON_HOST_SOURCE:=Python-$(PYTHON_HOST_VERSION).tar.bz2
PYTHON_HOST_MD5:=c57477edd6d18bd9eeca2f21add73919
PYTHON_HOST_SITE:=http://www.python.org/ftp/python/$(PYTHON_HOST_VERSION)
PYTHON_HOST_DIR:=$(TARGET_TOOLCHAIN_DIR)/Python-$(PYTHON_HOST_VERSION)
PYTHON_HOST_BINARY:=$(PYTHON_HOST_DIR)/python

HOST_TOOLCHAIN_DIR:=$(FREETZ_BASE_DIR)/$(TOOLCHAIN_DIR)/host

PYTHON_HOST_TARGET_BINARY:=$(HOST_TOOLCHAIN_DIR)/usr/bin/python2.7

ifneq ($(strip $(DL_DIR)/$(PYTHON_HOST_SOURCE)), $(strip $(DL_DIR)/$(PYTHON_SOURCE)))
$(DL_DIR)/$(PYTHON_HOST_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(PYTHON_HOST_SOURCE) $(PYTHON_HOST_SITE) $(PYTHON_HOST_MD5)
endif

$(PYTHON_HOST_DIR)/.unpacked: $(DL_DIR)/$(PYTHON_HOST_SOURCE) | $(TARGET_TOOLCHAIN_DIR)
	tar -C $(TARGET_TOOLCHAIN_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(PYTHON_HOST_SOURCE)
	touch $@

$(PYTHON_HOST_DIR)/.configured: $(PYTHON_HOST_DIR)/.unpacked
	(cd $(PYTHON_HOST_DIR); rm -rf config.cache; \
		CC=$(HOSTCC) \
		CFLAGS="$(HOST_CFLAGS)" \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_HOST_NAME) \
		--target=$(GNU_HOST_NAME) \
		--prefix=/usr \
	);
	touch $@

$(PYTHON_HOST_BINARY): $(PYTHON_HOST_DIR)/.configured
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PYTHON_HOST_DIR) \
		all Parser/pgen
	touch -c $@

$(PYTHON_HOST_TARGET_BINARY): $(PYTHON_HOST_BINARY)
	mkdir -p $(HOST_TOOLCHAIN_DIR)
	PATH=$(TARGET_PATH) \
		$(MAKE) -C $(PYTHON_HOST_DIR) \
		DESTDIR="$(HOST_TOOLCHAIN_DIR)" \
		install
	cp -a $(PYTHON_HOST_BINARY) $(PYTHON_HOST_DIR)/Parser/pgen \
		$(HOST_TOOLCHAIN_DIR)/usr/bin

python-host: $(PYTHON_HOST_TARGET_BINARY)

python-host-source: $(PYTHON_HOST_DIR)/.unpacked

python-host-configured: $(PYTHON_HOST_DIR)/.configured

python-host-precompiled: $(PYTHON_HOST_BINARY)

python-host-clean:
	-$(MAKE) -C $(PYTHON_HOST_DIR) clean

python-host-dirclean:
	$(RM) -r \
		$(PYTHON_HOST_DIR) \
		$(PYTHON_HOST_TARGET_BINARY) \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/2to3 \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/easy_install* \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/idle \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/pgen \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/pydoc \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/python* \
		$(HOST_TOOLCHAIN_DIR)/usr/bin/smtpd.py \
		$(HOST_TOOLCHAIN_DIR)/usr/include/python2.7 \
		$(HOST_TOOLCHAIN_DIR)/usr/lib/libpython2.7.* \
		$(HOST_TOOLCHAIN_DIR)/usr/lib/python2.7 \
		$(HOST_TOOLCHAIN_DIR)/usr/lib/pkgconfig/python* \
		$(HOST_TOOLCHAIN_DIR)/usr/share/python2.7 \
		$(HOST_TOOLCHAIN_DIR)/usr/share/man/man1/python2.7.1
	find $(HOST_TOOLCHAIN_DIR)/usr/ -depth -empty -delete

.PHONY: python-host
