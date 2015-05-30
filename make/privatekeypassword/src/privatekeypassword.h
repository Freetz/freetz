/*
 * Copyright (C) 2015 freetz.org, Licensed under GPLv2
 */

#ifndef _PRIVATEKEYPASSWORD_H
#define _PRIVATEKEYPASSWORD_H

/*
 * determines the password of the private key of Fritz!Box SSL-certificate
 * returns password length or -1 in case of an error
 */
int get_private_key_password(char *password_buf, size_t password_buf_size);

#endif
