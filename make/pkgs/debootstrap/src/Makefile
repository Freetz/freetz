TARGET=pkgdetails

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(CC) -o $@ $^ $(LDFLAGS)

$(TARGET).o: $(TARGET).c
	$(CC) -c -o $@ $^ $(CFLAGS)

clean:
	$(RM) $(TARGET) $(TARGET).o
