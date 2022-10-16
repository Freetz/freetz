CFLAGS=-Wall

all: lzma2eva eva2lzma bzimage2eva eva2bzimage

lzma2eva: LDLIBS+=-lz

clean:
	rm -f *.o lzma2eva eva2lzma bzimage2eva eva2bzimage

.PHONY: all clean
