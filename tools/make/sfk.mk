SFK_VERSION:=1.6.3
SFK_VERSION_SHORT:=163
SFK_SOURCE:=sfk$(SFK_VERSION_SHORT).zip
SFK_SOURCE_MD5:=cdb57789363bc0b13c07e8fcd65a973e
SFK_SITE:=@SF/swissfileknife/1-swissfileknife/$(SFK_VERSION)
SFK_DIR:=$(TOOLS_SOURCE_DIR)/sfk$(SFK_VERSION_SHORT)
SFK_MAKE_DIR:=$(TOOLS_DIR)/make
SFK_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)

$(DL_DIR)/$(SFK_SOURCE): | $(DL_DIR)
	$(DL_TOOL) $(DL_DIR) $(SFK_SOURCE) $(SFK_SITE) $(SFK_SOURCE_MD5)

sfk-source: $(DL_DIR)/$(SFK_SOURCE)

$(SFK_DIR)/.unpacked: $(DL_DIR)/$(SFK_SOURCE) | $(TOOLS_SOURCE_DIR)
	unzip -d $(TOOLS_SOURCE_DIR) $(DL_DIR)/$(SFK_SOURCE)
	touch $@

$(SFK_DIR)/sfk: $(SFK_DIR)/.unpacked
	$(TOOLS_CXX) -s $(SFK_DIR)/sfk.cpp $(SFK_DIR)/sfknet.cpp $(SFK_DIR)/patch.cpp $(SFK_DIR)/inst.cpp -o $(SFK_DIR)/sfk

$(TOOLS_DIR)/sfk: $(SFK_DIR)/sfk
	cp $(SFK_DIR)/sfk $(TOOLS_DIR)/sfk

sfk: $(TOOLS_DIR)/sfk

sfk-clean:
	$(RM) $(SFK_DIR)/sfk

sfk-dirclean:
	$(RM) -r $(SFK_DIR)

sfk-distclean:
	$(RM) $(TOOLS_DIR)/sfk

