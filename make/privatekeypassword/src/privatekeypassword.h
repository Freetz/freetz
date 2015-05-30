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

/*
 * a possible implementation of OpenSSL's pem_password_cb function (s. https://www.openssl.org/docs/crypto/pem.html for details)
 * returns password length or 0 in case of an error
 *
 * provided implementation assumes the returned password will be cached in memory pointed to by userdata
 */
int get_private_key_password_OpenSSL_callback(char *buf, int size, int rwflag, void *userdata);

#endif
