/*
 * Compatibility library
 * Overites functions
 * (C) 2011 Oliver Metz, Ralf Friedl
 *
 */

// #define DEBUG

#define _XOPEN_SOURCE	500
#define _SVID_SOURCE

#include <stdio.h>
#include <string.h>

#include <limits.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <sys/types.h>
#include <pwd.h>

extern int real_rand ();

#define	g_bStorageUsers	1	// local in libctlusb
#ifndef	g_bStorageUsers
static short g_bStorageUsers;
#endif

struct user {
  struct user *	u_next;		// u00
  int		u_enabled;		// u04
  char *	u_user;			// u08
  char *	u_pass;			// u12
  char *	u_passint;		// u16
  int		u20;
  int		u24;
#ifdef D_STRUCT_V2
  int		u28;
  int		u_boxusr_nr;	// u32
#endif
#ifdef D_STRUCT_V1
  int		u_boxusr_nr;	// u28
#endif
};


struct x {
  int		x00;
  char *	x_pass;
  int		x08;
  int		x12;
  int		x16;
  int		x20;
  int		x24;
  int		x28;
  int		x32;
#ifdef D_STRUCT_V2
  int		x36;
  int		x40;
  struct user *        x_users;        // x44
#endif
#ifdef D_STRUCT_V1
  struct user *        x_users;        // x36
#endif
};

struct T_USBCFG_config {
  struct x *	x00;
  void *	x04;
  void *	x08;
  void *	x12;
  void *	x16;
  void *	x20;
};

struct FTP_config {
  int f00;
  char *f_passwd;
};

struct AR7CFG_config {
  int a00;
  int a04;
  int a08;
  int a12;
  int a16;
  int a20;
  int a24;
  int a28;
  int a32;
  int a36;
  int a40;
  struct FTP_config *a_FTP_config;
};
extern struct AR7CFG_config *GetAddrOfAR7CFG_config();

struct T_USBCFG_config USBCFG_config;

#define	AVM_PW_GECOS_FTP_USER	"ftp user"
#define	AVM_PW_GECOS_BOX_USER	"box user"

static void
add_linux_ftp_user (FILE *fp, char const *name, char const *pass, uid_t uid, int user_map)
{
  int i;
  struct passwd pwd, *pw = &pwd;

  pw->pw_name = (char *)name;
  if (pass && *pass) {
    int i;
#ifdef AVM
    char salt[11];
#else
    char salt[12];
#endif
    for (i = 3; i < sizeof (salt); i++) {
      unsigned int r = real_rand ();
      unsigned int c;
#ifdef AVM
      c = (r % 26) + 'a';
#else
      c = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789./"[r % 64];
#endif
      salt[i] = c;
    }
    salt[0] = '$';
    salt[1] = '1';
    salt[2] = '$';
    salt[sizeof (salt) - 1] = 0;
    pw->pw_passwd = crypt (pass, salt);
  }
  else
    pw->pw_passwd = "any";
  pw->pw_uid = uid;
  pw->pw_gid = 0;
  if (user_map) {
    pw->pw_gecos = AVM_PW_GECOS_BOX_USER;
    pw->pw_dir = "/home-not-used";
  }
  else {
    pw->pw_gecos = AVM_PW_GECOS_FTP_USER;
    pw->pw_dir = "/var/media/ftp";
  }
  pw->pw_shell = "/bin/sh";
  putpwent (pw, fp);
}

static void
write_passwd (int user_map)
{
  struct user *up;
  FILE *fp_passwd = NULL, *fp_users = NULL;
  struct passwd *pw;
  char *cp;
  char path_buf[PATH_MAX];

  if (user_map) {
    fp_users = fopen ("/var/users.map", "w");
    if (!fp_users)
      goto end;
  }
  fp_passwd = fopen ("/var/tmp/passwd.tmp", "w");
  if (!fp_passwd)
    goto end;
  setpwent ();
  for (;;) {
    pw = getpwent ();
    if (!pw)
      break;
#ifdef AVM
    if (strcmp (pw->pw_name, "root") == 0)
      putpwent (pw, fp_passwd);
#else
    if (strcmp (pw->pw_gecos, AVM_PW_GECOS_FTP_USER) != 0
	&& strcmp (pw->pw_gecos, AVM_PW_GECOS_BOX_USER) != 0)
      putpwent (pw, fp_passwd);
#endif
  }
  endpwent ();
  struct x *xp = USBCFG_config.x00;
  if ( xp == NULL) {
    add_linux_ftp_user (fp_passwd, "ftpuser", GetAddrOfAR7CFG_config ()->a_FTP_config->f_passwd, 1000, 0);
  }
  else if (!user_map) {
    if (g_bStorageUsers && xp->x32) {
      int i, uid;
      for (up = xp->x_users, i = 1; up; up = up->u_next, i++) {
	if (up->u_enabled && up->u_user) {
	  uid = 1000 + i;
	  add_linux_ftp_user (fp_passwd, up->u_user, up->u_pass, uid, 0);
	}
      }
    }
    else {
      add_linux_ftp_user (fp_passwd, "ftpuser", xp->x_pass, 1000, 0);
    }
  }
  else {
    for (up = xp->x_users; up; up = up->u_next) {
      if (up->u_enabled && up->u_user) {
	int uid;
	sprintf (path_buf, "boxusr%u", up->u_boxusr_nr);
	uid = 1000 + up->u_boxusr_nr;
	add_linux_ftp_user (fp_passwd, path_buf, up->u_pass, uid, 1);
	fprintf (fp_users, "%s = \"%s\"\n", path_buf, up->u_user);
#ifdef D_STRUCT_V2
       sprintf (path_buf, "boxusr%uint", up->u_boxusr_nr);
       uid = 2000 + up->u_boxusr_nr;
       add_linux_ftp_user (fp_passwd, path_buf, up->u_passint, uid, 1);
#endif
      }
    }
  }
  fclose (fp_passwd);
  cp = realpath ("/etc/passwd", path_buf);
  if (cp == path_buf)
    rename ("/var/tmp/passwd.tmp", path_buf);
 end:
  if (fp_users)
    fclose (fp_users);
  return;
}

void
write_etc_passwd ()
{
  write_passwd (0);
}

void
write_etc_passwd_and_users_map ()
{
  write_passwd (1);
}

#ifdef DEBUG
void
show_structure_layout_version ()
{
#ifdef D_STRUCT_V2
	printf ("compiled for 2nd struct layout version");
#elif D_STRUCT_V1
	printf ("compiled for 1st struct layout version");
#else
	printf ("compiled for no struct layout version");
#endif

}
#endif
