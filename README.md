# Welcome to Freetz-NG

```
 _____              _            _   _  ____
|  ___| __ ___  ___| |_ ____    | \ | |/ ___|
| |_ | '__/ _ \/ _ \ __|_  /____|  \| | |  _
|  _|| | |  __/  __/ |_ / /_____| |\  | |_| |
|_|  |_|  \___|\___|\__/___|    |_| \_|\____|

```

Freetz-NG is a fork of Freetz.
More features - less bugs!

### Requirements:
 * You need an up to date Linux System with some [prerequisites](docs/wiki/10_Beginner/install.de.md#installation-der-ben%C3%B6tigten-pakete-ubuntu).
 * Or download a ready-to-use VM like Gismotro's [Freetz-Linux](https://freetz.digital-eliteboard.com/?dir=Teamserver/Freetz/Freetz-VM/VirtualBox/).

### Quickstart:
```
  git clone https://github.com/Freetz-NG/freetz-ng ~/freetz-ng
  cd ~/freetz-ng
  make menuconfig
  make
  # make help
```

### Flash firmware:
```
  # make push-firmware
  tools/push_firmware -h
```

### Update GIT:
```
  git pull
```

### Show GIT states:
```
  git status
  git diff --no-prefix # --cached
  git log --graph # --oneline
```

### Delete local changes:
```
  git fetch --all --prune
  git reset --hard origin/HEAD
  git clean -fd
```

### Mirrors:
```
  git clone https://gitlab.com/Freetz-NG/freetz-ng ~/freetz-ng
  git clone https://bitbucket.org/Freetz-NG/freetz-ng ~/freetz-ng
```

### Not recommended:
```
  svn co https://github.com/Freetz-NG/freetz-ng/trunk ~/freetz-ng
```

### Documentation:
See [https://freetz-ng.github.io/](https://freetz-ng.github.io/) (or [docs/](docs/README.md)).

