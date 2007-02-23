HASERL_VERSION:=0.9.16
HASERL_SOURCE:=haserl-$(HASERL_VERSION).tar.gz
HASERL_SITE:=http://mesh.dl.sourceforge.net/sourceforge/haserl
HASERL_DIR:=$(SOURCE_DIR)/haserl-$(HASERL_VERSION)
HASERL_TARGET_DIR:=root/usr/bin
HASERL_TARGET_BINARY:=haserl


$(DL_DIR)/$(HASERL_SOURCE):
	wget -P $(DL_DIR) $(HASERL_SITE)/$(HASERL_SOURCE)

$(HASERL_DIR)/.unpacked: $(DL_DIR)/$(HASERL_SOURCE)
	tar -C $(SOURCE_DIR) $(VERBOSE) -xzf $(DL_DIR)/$(HASERL_SOURCE)
	touch $@

$(HASERL_DIR)/.configured: $(HASERL_DIR)/.unpacked
	( cd $(HASERL_DIR); rm -f config.{cache,status}; \
		$(TARGET_CONFIGURE_OPTS) \
		CFLAGS="$(TARGET_CFLAGS)" \
		LDFLAGS="-static-libgcc" \
		./configure \
		--target=$(GNU_TARGET_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--build=$(GNU_HOST_NAME) \
		--program-prefix="" \
		--program-suffix="" \
		--prefix=/usr \
		--exec-prefix=/usr \
		--bindir=/usr/bin \
		--datadir=/usr/share \
		--includedir=/usr/include \
		--infodir=/usr/share/info \
		--libdir=/usr/lib \
		--libexecdir=/usr/lib \
		--localstatedir=/var \
		--mandir=/usr/share/man \
		--sbindir=/usr/sbin \
		--sysconfdir=/etc \
		$(DISABLE_NLS) \
		$(DISABLE_LARGEFILE) \
	    );
	touch $@

$(HASERL_DIR)/$(HASERL_TARGET_BINARY): $(HASERL_DIR)/.configured
	PATH="$(TARGET_PATH)" $(MAKE) CROSS="$(TARGET_MAKE_PATH)/$(TARGET_CROSS)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		-C $(HASERL_DIR)

haserl-precompiled: $(HASERL_DIR)/$(HASERL_TARGET_BINARY)
	$(TARGET_STRIP) $(HASERL_DIR)/src/$(HASERL_TARGET_BINARY)
	cp $(HASERL_DIR)/src/$(HASERL_TARGET_BINARY) $(HASERL_TARGET_DIR)/

haserl-source: $(HASERL_DIR)/.unpacked

haserl-clean:
	-$(MAKE) -C $(HASERL_DIR) clean

haserl-dirclean:
	rm -rf $(HASERL_DIR)
