# Patch GUEST
The guest networks could be enabled in ip-client mode.<br>
<br>

The DHCP server is not working on guest networks. You could:
 * Change DHCP settings in ar7.cfg.
 * Configure dnsmasq for guest* interfaces.
 * Change the bridging: I moved the guest1 interface to the lan bridge to make it work.
   It means the guest is not really a guest, but just a 2nd AP,  which is actually what I wanted:

	```
	$ brctl show
	bridge name     bridge id               STP enabled     interfaces
	lan             8000.bc05439f6953       no              eth0
	                                                        ath0
	guest           8000.bc05439f6953       no              guest1
	hotspot         8000.bc05439f6953       no
	```

	```
	$ brctl delif guest guest1
	```
	```
	$ brctl addif lan guest1
	```

	```
	$ brctl show
	bridge name     bridge id               STP enabled     interfaces
	lan             8000.bc05439f6953       no              eth0
	                                                        ath0
	                                                        guest1
	guest           8000.bc05439f6953       no
	hotspot         8000.bc05439f6953       no
	```

