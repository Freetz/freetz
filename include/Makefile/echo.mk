
# We want build output like:
# "---> package/lynx: downloading... preparing... configuring... building... done."
# Actually there are two problems:
# 1. We can't use _ECHO_START_INT in $(SUBMAKE) / $(TOOLS_SUBMAKE) context.
# 2. Dot files are deleted within every package. But once at start would be enough.
# Usage:
# $(call _ECHO,text)
ECHO_ITEM_1ST:=$(SOURCE_DIR_ROOT)/.echo_item_1st
ECHO_ITEM_OLD:=$(SOURCE_DIR_ROOT)/.echo_item_old
ECHO_ITEM_TMP:=$(SOURCE_DIR_ROOT)/.echo_item_tmp
ECHO_ITEM_NEW:=$(SOURCE_DIR_ROOT)/.echo_item_new
ECHO_ITEM_END:=$(SOURCE_DIR_ROOT)/.echo_item_end

define _ECHO_START_ARG
	[ -n "$2" ] && step="/$2" || step=""; \
	[ -n "$3" ] && step="$$step/$3"; \
	case "$1$(PKG_TYPE)" in \
		BIN)	echo -n "package/$(pkg)"         >$(ECHO_ITEM_TMP) ;; \
		LIB)	echo -n "library/$(pkg)"         >$(ECHO_ITEM_TMP) ;; \
		HTL)	echo -n "tools/$(pkg)"           >$(ECHO_ITEM_TMP) ;; \
		KTC)	echo -n "toolchain/kernel$$step" >$(ECHO_ITEM_TMP) ;; \
		TTC)	echo -n "toolchain/target$$step" >$(ECHO_ITEM_TMP) ;; \
		KRN)	echo -n "kernel"                 >$(ECHO_ITEM_TMP) ;; \
	esac;
endef

define _ECHO_START_INT
	$(call _ECHO_START_ARG,$(2),$(3),$(4)) \
	if ! diff -q $(ECHO_ITEM_TMP) $(ECHO_ITEM_NEW) >/dev/null 2>&1 || [ ! -e $(ECHO_ITEM_1ST) ]; then \
		$(call _ECHO_DONE) \
		[ -s $(ECHO_ITEM_TMP) ] && cat $(ECHO_ITEM_TMP) > $(ECHO_ITEM_NEW) 2>/dev/null; \
		[ -s $(ECHO_ITEM_NEW) ] || cat $(ECHO_ITEM_OLD) > $(ECHO_ITEM_NEW) 2>/dev/null; \
		if [ -s "$(ECHO_ITEM_NEW)" ]; then \
			echo -ne "\e[48;5;90m---> "; \
			cat $(ECHO_ITEM_NEW) 2>/dev/null | tee $(ECHO_ITEM_OLD); \
			echo -ne "\e[49m ... "; \
			touch $(ECHO_ITEM_END); \
			touch $(ECHO_ITEM_1ST); \
		fi; \
	fi;
endef

define _ECHO
	$(call _ECHO_START_INT,$(1),$(2),$(3),$(4)) \
	echo -ne "\e[48;5;56m$(1)\e[49m ... ";
endef

define _ECHO_DONE
	if [ -e $(ECHO_ITEM_END) -a -e $(ECHO_ITEM_NEW) -a -e $(ECHO_ITEM_1ST) ]; then \
		echo -e "\e[48;5;26mdone\e[49m."; \
		$(RM) $(ECHO_ITEM_END) $(ECHO_ITEM_1ST); \
	fi;
endef

