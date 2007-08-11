TAR_VERSION:=1.15.1
TAR_SOURCE:=tar-$(TAR_VERSION).tar.bz2
TAR_CYGWIN_PATCH:=cygwin-tar-$(TAR_VERSION)-4.patch
TAR_SITE:=http://ftp.gnu.org/gnu/tar
TAR_DIR:=$(SOURCE_DIR)/tar-$(TAR_VERSION)
TAR_MAKE_DIR:=$(TOOLS_DIR)/make
TAR_BINARY:=tar

$(DL_DIR)/$(TAR_SOURCE):
	wget -P $(DL_DIR) $(TAR_SITE)/$(TAR_SOURCE)

ifeq ($(strip $(TERM)),cygwin)
TAR_BINARY:=tar.exe
$(TAR_DIR)/.unpacked: $(DL_DIR)/$(TAR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(TAR_SOURCE)
		@echo "Cygwin detected - applying 'tar' patch"
		patch -d $(SOURCE_DIR) -p0 < $(TAR_MAKE_DIR)/patches/$(TAR_CYGWIN_PATCH)
	touch $@
else
$(TAR_DIR)/.unpacked: $(DL_DIR)/$(TAR_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xjf $(DL_DIR)/$(TAR_SOURCE)
	touch $@
endif

$(TAR_DIR)/.configured: $(TAR_DIR)/.unpacked
	(cd $(TAR_DIR); rm -rf config.cache; \
		CFLAGS="-O2 -Wall" \
		CC="$(TOOLS_CC)" \
		./configure \
		--prefix=/usr \
		$(DISABLE_NLS) \
	);
	touch $@

$(TAR_DIR)/src/$(TAR_BINARY): $(TAR_DIR)/.configured
	$(MAKE) CC="$(TOOLS_CC)" \
		-C $(TAR_DIR) all
	touch -c $@

$(TOOLS_DIR)/$(TAR_BINARY): $(TAR_DIR)/src/$(TAR_BINARY)
	cp $(TAR_DIR)/src/$(TAR_BINARY) $(TOOLS_DIR)/$(TAR_BINARY)
	strip $(TOOLS_DIR)/$(TAR_BINARY)

tar: $(TOOLS_DIR)/$(TAR_BINARY)

tar-source: $(TAR_DIR)/.unpacked

tar-clean:
	-$(MAKE) -C $(TAR_DIR) clean

tar-dirclean:
	rm -rf $(TAR_DIR)

tar-distclean: tar-dirclean
	rm -f $(TOOLS_DIR)/$(TAR_BINARY)
