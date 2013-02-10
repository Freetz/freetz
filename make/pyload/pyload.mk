$(call PKG_INIT_BIN, cff39521889e)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_SITE:=hg@https://bitbucket.org/spoob/pyload

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/opt/pyLoad/pyLoadCore.py

$(PKG)_BUILD_PREREQ += hg
$(PKG)_BUILD_PREREQ_HINT := Hint: on Debian-like systems this binary is provided by the mercurial package (sudo apt-get install mercurial)

define pyLoad/build/files
.build-prereq-checked
.unpacked
.configured
.exclude
endef

define pyLoad/unnecessary/files
docs
icons
LICENSE
locale
module/cli
module/gui
module/lib/wsgiserver/LICENSE.txt
module/web/servers
pavement.py
pyLoadCli.py
pyLoadGui.py
README
setup.cfg
systemCheck.py
testlinks.txt
tests
endef

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.exclude: $($(PKG)_DIR)/.configured
	@echo -n > $@; \
	echo $(call newline2space,$(pyLoad/build/files)) | tr " " "\n" >> $@; \
	echo $(call newline2space,$(pyLoad/unnecessary/files)) | tr " " "\n" >> $@;

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.exclude
	@mkdir -p $(dir $@); \
	tar -c -C $(PYLOAD_DIR) --exclude-from=$< . | tar -x -C $(dir $@); \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	$(RM) $(PYLOAD_DIR)/.exclude

$(pkg)-uninstall:
	$(RM) -r $(dir $(PYLOAD_TARGET_BINARY))

$(PKG_FINISH)
