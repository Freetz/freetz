TARGET=target-tester

all: $(TARGET)

$(TARGET): $(TARGET).o
	$(CC) -o $@ $^

$(TARGET).o: target-tester.c
	$(CC) -c -o $@ $^ $(CFLAGS)

clean:
	$(RM) $(TARGET) $(TARGET).o
