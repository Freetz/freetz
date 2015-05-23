PROG = box_key_password_ftpd_proxy

CC = gcc
override CFLAGS += -Wall -std=c99

$(PROG): $(PROG).o

$(PROG).o: $(PROG).c

clean:
	@$(RM) $(PROG).o $(PROG)
