FROM ubuntu:14.04
ARG BUILD_USER=builduser

RUN \
    apt-get -y update && apt-get -y upgrade && apt-get -y dist-upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install \
    bash locales libarchive-zip-perl  \
    pv cpio rsync kmod execstack imagemagick inkscape graphicsmagick subversion git bc unar wget sudo gcc g++ binutils autoconf automake \
    libtool make bzip2 libncurses5-dev libreadline-dev zlib1g-dev flex bison patch texinfo tofrodos gettext pkg-config ecj fastjar realpath \
    perl libstring-crc32-perl ruby ruby1.9 gawk python libusb-dev unzip intltool libacl1-dev libcap-dev libc6-dev-i386 lib32ncurses5-dev \
    gcc-multilib lib32stdc++6 libglib2.0-dev ccache cmake lib32z1-dev libsqlite3-dev sqlite3 netcat curl openssl build-essential automake1.9 \
    autopoint \
 && DEBIAN_FRONTEND=noninteractive apt-get -y clean \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.utf8 && locale-gen de_DE.UTF-8 && update-locale \
 && CAX3="/usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt"; \
    for x in $(find /etc/ssl/certs/ ! -type d); do [ "$(realpath $x)"  = "/usr/share/ca-certificates/mozilla/DST_Root_CA_X3.crt" ] && CAX3="$CAX3 $x"; done; \
    rm -f $CAX3 \
 && URL="https://github.com/facebook/zstd/releases/download/v1.4.9/zstd-1.4.9.tar.gz" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && wget "$URL" && tar xvf "${URL##*/}" --strip-components=1 &&                make && make install \
 && URL="https://ftp.gnu.org/gnu/cpio/cpio-2.12.tar.bz2" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && wget "$URL" && tar xvf "${URL##*/}" --strip-components=1 && ./configure && make && make install \
 && URL="https://ftp.gnu.org/gnu/make/make-3.82.tar.bz2" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && wget "$URL" && tar xvf "${URL##*/}" --strip-components=1 && ./configure && make && make install \
 && URL="https://ftp.osuosl.org/pub/blfs/conglomeration/cmake/cmake-3.4.3.tar.gz" && \
    DIR="$(mktemp -d)" && [ -d "$DIR" ] && cd "$DIR" && wget "$URL" && tar xvf "${URL##*/}" --strip-components=1 && ./configure && make && make install \
 && useradd $BUILD_USER -s $(which bash) -M -d /workspace && \
    echo "$BUILD_USER ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    mkdir -p /workspace && \
    echo -e 'umask 0022\nexport LANG=en_US.utf8' > /workspace/.profile && \
    chown -R $BUILD_USER /workspace

WORKDIR /workspace
ENV BUILD_USER=$BUILD_USER
ADD entrypoint.sh /usr/local/bin
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
