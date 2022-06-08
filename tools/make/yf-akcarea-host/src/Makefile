ifneq ($(findstring clean,$(MAKECMDGOALS)),clean)
ifeq ($(LIBFDT_DIR),)
	$(error this Makefile expects the location prefix of libfdt to be provided by setting the variable LIBFDT_DIR)
endif
endif

CC = gcc
RM = rm -f

OPT = -O2
BITNESS = -m32
override CFLAGS   += $(OPT) $(BITNESS) -std=c99 -W -Wall
override CPPFLAGS += -I$(LIBFDT_DIR)/include -DUSE_STRIPPED_AVM_KERNEL_CONFIG_H
override LDFLAGS  += $(BITNESS)
override LDLIBS   += -L$(LIBFDT_DIR)/lib -lfdt

BASENAME = avm_kernel_config

BINS     = $(BASENAME).bin2asm $(BASENAME).extract
BIN_SRCS = $(BINS:%=%.c)
BIN_HDRS = $(BASENAME).h $(BASENAME)_macros.h
BIN_OBJS = $(BIN_SRCS:%.c=%.o)

HELPER_SRCS = lib_$(BASENAME).c memory_mapped_file.c
HELPER_HDRS = lib_$(BASENAME).h memory_mapped_file.h
HELPER_OBJS = $(HELPER_SRCS:%.c=%.o)

all: $(BINS)

$(BINS): $(HELPER_OBJS)

$(HELPER_OBJS): $(HELPER_SRCS) $(HELPER_HDRS)
$(BIN_OBJS): $(BIN_SRCS) $(BIN_HDRS) $(HELPER_HDRS)

clean:
	-$(RM) *.o $(BINS)

.PHONY: all clean
