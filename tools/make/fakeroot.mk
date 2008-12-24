FAKEROOT_VERSION:=1.11.4
FAKEROOT_SOURCE:=fakeroot_$(FAKEROOT_VERSION).tar.gz
FAKEROOT_SOURCE_MD5:=61d29fcb868c5f9c3d0a3686ce45263e
FAKEROOT_SITE:=http://ftp.debian.org/debian/pool/main/f/fakeroot
FAKEROOT_DIR:=$(SOURCE_DIR)/fakeroot-$(FAKEROOT_VERSION)
FAKEROOT_MAKE_DIR:=$(TOOLS_DIR)/make
FAKEROOT_DESTDIR:=$(shell pwd)/$(TOOLS_DIR)


$(DL_DIR)/$(FAKEROOT_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(TOOLS_DOT_CONFIG) $(FAKEROOT_SOURCE) $(FAKEROOT_SITE) $(FAKEROOT_SOURCE_MD5)

fakeroot-source: $(DL_DIR)/$(FAKEROOT_SOURCE)

$(FAKEROOT_DIR)/.unpacked: $(DL_DIR)/$(FAKEROOT_SOURCE)
	@rm -rf $(FAKEROOT_DIR) && mkdir -p $(FAKEROOT_DIR)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(FAKEROOT_SOURCE)
	$(SED) -i "s,getopt --version,getopt --version 2>/dev/null," \
		$(FAKEROOT_DIR)/scripts/fakeroot.in
	for i in $(FAKEROOT_MAKE_DIR)/patches/*.fakeroot.patch; do \
		$(PATCH_TOOL) $(FAKEROOT_DIR) $$i; \
	done
	touch $@

$(FAKEROOT_DIR)/.configured: $(FAKEROOT_DIR)/.unpacked
	(cd $(FAKEROOT_DIR); rm -rf config.cache; \
		CFLAGS="-O3 -Wall" \
		CC="$(TOOLS_CC)" \
		./configure \
		--prefix=/usr \
		--enable-shared \
		$(DISABLE_NLS) \
	);
	touch $(FAKEROOT_DIR)/.configured

$(FAKEROOT_DIR)/faked: $(FAKEROOT_DIR)/.configured
	$(MAKE) -C $(FAKEROOT_DIR)

$(TOOLS_DIR)/usr/bin/fakeroot: $(FAKEROOT_DIR)/faked
	$(MAKE) DESTDIR=$(FAKEROOT_DESTDIR) -C $(FAKEROOT_DIR) install
	$(SED) -i -e 's,^PREFIX=.*,PREFIX=$(FAKEROOT_DESTDIR)/usr,g' $(TOOLS_DIR)/usr/bin/fakeroot
	$(SED) -i -e 's,^BINDIR=.*,BINDIR=$(FAKEROOT_DESTDIR)/usr/bin,g' $(TOOLS_DIR)/usr/bin/fakeroot
	$(SED) -i -e 's,^PATHS=.*,PATHS=$(FAKEROOT_DESTDIR)/usr/lib,g' $(TOOLS_DIR)/usr/bin/fakeroot

fakeroot: $(TOOLS_DIR)/usr/bin/fakeroot

fakeroot-clean:
	$(MAKE) -C $(FAKEROOT_DIR) clean

fakeroot-dirclean:
	$(RM) -r $(FAKEROOT_DIR)

fakeroot-distclean:
	$(RM) -r $(TOOLS_DIR)/usr
