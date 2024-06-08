#!/bin/bash

################################################################################################
################################################################################################

# shellcheck disable=SC2155
# shellcheck disable=SC2086
# shellcheck disable=SC2164
# shellcheck disable=SC2046
# shellcheck disable=SC2006

################################################################################################
################################################################################################

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y bash bc binutils bison build-essential coreutils diffutils \
	findutils flex gawk gcc g++ gettext grep gzip m4 make nano patch \
	perl python3 sed tar texinfo tree xz-utils zstd zip unzip
sudo apt-get autoremove -y

################################################################################################
################################################################################################

set +h
umask 022

export LO_HOME=$HOME/lo
export LO_TARGET=x86_64-lo-linux-gnu
export LC_ALL=POSIX
export MAKEFLAGS=-j$(nproc)

PATH=/usr/bin
if [ ! -L /bin ]; then
	PATH=/bin:$PATH;
fi

export PATH=$LO_HOME/tools/bin:$PATH
export CONFIG_SITE=$LO_HOME/usr/share/config.site

################################################################################################
################################################################################################

mkdir -p $LO_HOME/{boot,dev,etc,home,media,mnt,opt,run,srv,var/log}
mkdir -p $LO_HOME/usr/{bin,lib,lib64,sbin,include,local}
mkdir -p $LO_HOME/{tools,source}

install -d -m 0555 $LO_HOME/proc/
install -d -m 0700 $LO_HOME/root/
install -d -m 0555 $LO_HOME/sys/
install -d -m 1777 $LO_HOME/tmp/
install -d -m 1777 $LO_HOME/var/tmp/

ln -s usr/bin $LO_HOME/bin
ln -s usr/lib $LO_HOME/lib
ln -s usr/lib64 $LO_HOME/lib64
ln -s usr/bin $LO_HOME/sbin

################################################################################################
################################################################################################

SOURCE_PACKAGES=(
	"https://download.savannah.gnu.org/releases/acl/acl-2.3.2.tar.xz"
	"https://download.savannah.gnu.org/releases/attr/attr-2.5.2.tar.xz"
	"https://ftp.gnu.org/gnu/autoconf/autoconf-2.72.tar.xz"
	"https://ftp.gnu.org/gnu/automake/automake-1.16.5.tar.xz"
	"https://ftp.gnu.org/gnu/bash/bash-5.2.21.tar.gz"
	"https://www.linuxfromscratch.org/patches/lfs/12.1/bash-5.2.21-upstream_fixes-1.patch"
	"https://github.com/gavinhoward/bc/releases/download/6.7.5/bc-6.7.5.tar.xz"
	"https://ftp.gnu.org/gnu/binutils/binutils-2.42.tar.xz"
	"https://ftp.gnu.org/gnu/bison/bison-3.8.2.tar.xz"
	"https://www.sourceware.org/pub/bzip2/bzip2-1.0.8.tar.gz"
	"https://www.linuxfromscratch.org/patches/lfs/12.1/bzip2-1.0.8-install_docs-1.patch"
	"https://ftp.gnu.org/gnu/coreutils/coreutils-9.5.tar.xz"
	"https://www.linuxfromscratch.org/patches/lfs/development/coreutils-9.5-i18n-2.patch"
	"https://www.linuxfromscratch.org/patches/lfs/12.1/coreutils-9.4-i18n-1.patch"
	"https://ftp.gnu.org/gnu/diffutils/diffutils-3.10.tar.xz"
	"https://downloads.sourceforge.net/project/e2fsprogs/e2fsprogs/v1.47.1/e2fsprogs-1.47.1.tar.gz"
	"https://sourceware.org/ftp/elfutils/0.191/elfutils-0.191.tar.bz2"
	"https://prdownloads.sourceforge.net/expat/expat-2.6.2.tar.xz"
	"https://astron.com/pub/file/file-5.45.tar.gz"
	"https://ftp.gnu.org/gnu/findutils/findutils-4.10.0.tar.xz"
	"https://github.com/westes/flex/releases/download/v2.6.4/flex-2.6.4.tar.gz"
	"https://ftp.gnu.org/gnu/gawk/gawk-5.3.0.tar.xz"
	"https://ftp.gnu.org/gnu/gcc/gcc-14.1.0/gcc-14.1.0.tar.xz"
	"https://ftp.gnu.org/gnu/gettext/gettext-0.22.5.tar.xz"
	"https://ftp.gnu.org/gnu/glibc/glibc-2.39.tar.xz"
	"https://www.linuxfromscratch.org/patches/lfs/development/glibc-2.39-fhs-1.patch"
	"https://www.linuxfromscratch.org/patches/lfs/development/glibc-2.39-upstream_fix-2.patch"
	"https://ftp.gnu.org/gnu/gmp/gmp-6.3.0.tar.xz"
	"https://ftp.gnu.org/gnu/gnutls/gnutls-3.1.5.tar.xz"
	"https://ftp.gnu.org/gnu/gperf/gperf-3.1.tar.gz"
	"https://ftp.gnu.org/gnu/grep/grep-3.11.tar.xz"
	"https://ftp.gnu.org/gnu/groff/groff-1.23.0.tar.gz"
	"https://ftp.gnu.org/gnu/gzip/gzip-1.13.tar.xz"
	"https://github.com/Mic92/iana-etc/releases/download/20240502/iana-etc-20240502.tar.gz"
	"https://ftp.gnu.org/gnu/inetutils/inetutils-2.5.tar.xz"
	"https://launchpad.net/intltool/trunk/0.51.0/+download/intltool-0.51.0.tar.gz"
	"https://mirrors.edge.kernel.org/pub/linux/utils/net/iproute2/iproute2-6.9.0.tar.xz"
	"https://mirrors.edge.kernel.org/pub/linux/utils/kbd/kbd-2.6.4.tar.xz"
	"https://www.linuxfromscratch.org/patches/lfs/12.1/kbd-2.6.4-backspace-1.patch"
	"https://mirrors.edge.kernel.org/pub/linux/utils/kernel/kmod/kmod-32.tar.xz"
	"https://ftp.gnu.org/gnu/less/less-643.tar.gz"
	"https://mirrors.edge.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.70.tar.xz"
	"https://github.com/libffi/libffi/releases/download/v3.4.6/libffi-3.4.6.tar.gz"
	"https://ftp.gnu.org/gnu/libiconv/libiconv-1.17.tar.gz"
	"https://ftp.gnu.org/gnu/libidn/libidn-1.42.tar.gz"
	"https://ftp.gnu.org/gnu/libidn/libidn2-2.3.7.tar.gz"
	"https://ftp.gnu.org/gnu/libtasn1/libtasn1-4.19.0.tar.gz"
	"https://ftp.gnu.org/gnu/libtool/libtool-2.4.7.tar.gz"
	"https://ftp.gnu.org/gnu/libunistring/libunistring-1.2.tar.xz"
	"https://github.com/besser82/libxcrypt/releases/download/v4.4.36/libxcrypt-4.4.36.tar.xz"
	"https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.9.3.tar.xz"
	"https://github.com/lz4/lz4/releases/download/v1.9.4/lz4-1.9.4.tar.gz"
	"https://ftp.gnu.org/gnu/m4/m4-1.4.19.tar.xz"
	"https://ftp.gnu.org/gnu/make/make-4.4.1.tar.gz"
	"https://download.savannah.gnu.org/releases/man-db/man-db-2.12.1.tar.xz"
	"https://mirrors.edge.kernel.org/pub/linux/docs/man-pages/man-pages-6.8.tar.xz"
	"https://ftp.gnu.org/gnu/mpc/mpc-1.3.1.tar.gz"
	"https://ftp.gnu.org/gnu/mpfr/mpfr-4.2.1.tar.xz"
	"https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz"
	"https://ftp.gnu.org/gnu/nettle/nettle-3.9.1.tar.gz"
	"https://github.com/ninja-build/ninja/archive/v1.12.1/ninja-1.12.1.tar.gz"
	"https://www.openssl.org/source/openssl-3.3.1.tar.gz"
	"https://ftp.gnu.org/gnu/patch/patch-2.7.6.tar.xz"
	"https://www.cpan.org/src/5.0/perl-5.38.2.tar.xz"
	"https://distfiles.ariadne.space/pkgconf/pkgconf-2.2.0.tar.xz"
	"https://sourceforge.net/projects/procps-ng/files/Production/procps-ng-4.0.4.tar.xz"
	"https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.7.tar.xz"
	"https://www.python.org/ftp/python/3.12.4/Python-3.12.4.tar.xz"
	"https://www.python.org/ftp/python/doc/3.12.4/python-3.12.4-docs-html.tar.bz2"
	"https://ftp.gnu.org/gnu/readline/readline-8.2.tar.gz"
	"https://www.linuxfromscratch.org/patches/lfs/12.1/readline-8.2-upstream_fixes-3.patch"
	"https://ftp.gnu.org/gnu/scm/scm-5f4.tar.gz"
	"https://ftp.gnu.org/gnu/sed/sed-4.9.tar.xz"
	"https://github.com/shadow-maint/shadow/releases/download/4.15.1/shadow-4.15.1.tar.xz"
	"https://ftp.gnu.org/gnu/tar/tar-1.35.tar.xz"
	"https://downloads.sourceforge.net/tcl/tcl8.6.14-src.tar.gz"
	"https://downloads.sourceforge.net/tcl/tcl8.6.14-html.tar.gz"
	"https://ftp.gnu.org/gnu/texinfo/texinfo-7.1.tar.xz"
	"https://www.iana.org/time-zones/repository/releases/tzdata2024a.tar.gz"
	"https://www.kernel.org/pub/linux/utils/util-linux/v2.40/util-linux-2.40.1.tar.xz"
	"https://ftp.gnu.org/gnu/wget/wget-1.24.5.tar.gz"
	"https://ftp.gnu.org/gnu/wget/wget2-2.1.0.tar.gz"
	"https://cpan.metacpan.org/authors/id/T/TO/TODDR/XML-Parser-2.47.tar.gz"
	"https://github.com/tukaani-project/xz/releases/download/v5.6.2/xz-5.6.2.tar.xz"
	"https://zlib.net/fossils/zlib-1.3.1.tar.gz"
	"https://github.com/facebook/zstd/releases/download/v1.5.6/zstd-1.5.6.tar.gz"
)

for source_url in "${SOURCE_PACKAGES[@]}"; do
	wget $source_url --continue --no-verbose --quiet --directory-prefix=$LO_HOME/source
done

cd $LO_HOME/source || exit 0
for source_package in *.tar.xz *.tar.gz; do
	if [[ $source_package == *.tar.xz ]]; then
		tar -xJf $source_package
	elif [[ $source_package == *.tar.gz ]]; then
		tar -xzf $source_package
	elif [[ $source_package == *.tar.bz2 ]]; then
		tar -xjf $source_package
	fi
done

################################################################################################
################################################################################################

cd $LO_HOME/source/binutils-2.42
mkdir -p build && cd build
../configure \
	--prefix=$LO_HOME/tools \
	--with-sysroot=$LO_HOME \
	--target=$LO_TARGET \
	--disable-nls \
	--enable-gprofng=no \
	--disable-werror \
	--silent \
	--quiet \
	--enable-default-hash-style=gnu
make > /dev/null && make install > /dev/null

cd $LO_HOME/source/gcc-14.1.0
tar xJf ../mpfr-4.2.1.tar.xz && mv mpfr-4.2.1 mpfr
tar xJf ../gmp-6.3.0.tar.xz && mv gmp-6.3.0 gmp
tar xzf ../mpc-1.3.1.tar.gz && mv mpc-1.3.1 mpc
sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
mkdir -p build && cd build
../configure \
	--target=$LO_TARGET \
	--prefix=$LO_HOME/tools \
	--with-glibc-version=2.39 \
	--with-sysroot=$LO_HOME \
	--with-newlib \
	--without-headers \
	--enable-default-pie \
	--enable-default-ssp \
	--disable-nls \
	--disable-shared \
	--disable-multilib \
	--disable-threads \
	--disable-libatomic \
	--disable-libgomp \
	--disable-libquadmath \
	--disable-libssp \
	--disable-libvtv \
	--disable-libstdcxx \
	--silent \
	--quiet \
	--enable-languages=c,c++
make > /dev/null && make install > /dev/null
cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $($LO_TARGET-gcc -print-libgcc-file-name)`/include/limits.h

cd $LO_HOME/source/linux-6.9.3
make mrproper > /dev/null && make headers > /dev/null
find usr/include -type f ! -name '*.h' -delete
cp -r usr/include $LO_HOME/usr

cd $LO_HOME/source/glibc-2.39
ln -sf ../lib/ld-linux-x86-64.so.2 $LO_HOME/lib64
ln -sf ../lib/ld-linux-x86-64.so.2 $LO_HOME/lib64/ld-lsb-x86-64.so.3
patch -Np1 -i ../glibc-2.39-fhs-1.patch
mkdir -p build && cd build
echo "rootsbindir=/usr/sbin" > configparms
../configure \
	--prefix=/usr \
	--host=$LO_TARGET \
	--build=$(../scripts/config.guess) \
	--enable-kernel=4.19 \
	--with-headers=$LO_HOME/usr/include \
	--disable-nscd \
	--silent \
	--quiet \
	libc_cv_slibdir=/usr/lib
make > /dev/null && make DESTDIR=$LO_HOME install > /dev/null
sed '/RTLDLIST=/s@/usr@@g' -i $LO_HOME/usr/bin/ldd

cd $LO_HOME/source/gcc-14.1.0
mkdir -p build2 && cd build2
../libstdc++-v3/configure \
	--host=$LO_TARGET \
	--build=$(../config.guess) \
	--prefix=/usr \
	--disable-multilib \
	--disable-nls \
	--disable-libstdcxx-pch \
	--silent \
	--quiet \
	--with-gxx-include-dir=/tools/$LO_TARGET/include/c++/14.1.0
make > /dev/null
make DESTDIR=$LO_HOME install > /dev/null
rm $LO_HOME/usr/lib/lib{stdc++{,exp,fs},supc++}.la