FROM alpine:3.14
MAINTAINER Chang-Hsing Lee <changhsinglee@gmail.com>

ARG openocd_ver=0.11.0

# OpenOCD download URL
# https://sourceforge.net/projects/openocd/files/openocd/${openocd_ver}/openocd-${openocd_ver}.tar.bz2
# https://downloads.sourceforge.net/project/openocd/openocd/${openocd_ver}/openocd-${openocd_ver}.tar.bz2

RUN apk --no-cache add --virtual build-dependencies \
	\
# Install toolchain & library development files that used for compile OpenOCD (temporary)
	libusb-dev \
	libftdi1-dev \
	libgpiod-dev \
	hidapi-dev \
	build-base \
	automake \
	autoconf \
	libtool \
	wget && \
	\
# Install OpenOCD
wget https://sourceforge.net/projects/openocd/files/openocd/${openocd_ver}/openocd-${openocd_ver}.tar.bz2 && \
tar xf openocd-${openocd_ver}.tar.bz2 && cd openocd-${openocd_ver}/ && \
./configure \
	--prefix=/usr \
	--sysconfdir=/etc \
	--mandir=/usr/share/man \
	--localstatedir=/var \
	--disable-doxygen-html \
	--enable-bcm2835gpio \
	--enable-imx_gpio \
	--enable-sysfsgpio && \
make && make install && cd / && \
	\
# Remove toolchain & library development files
apk del --purge build-dependencies && \
	\
# Remove OpenOCD source code and man pages
rm -fr openocd-${openocd_ver}* /usr/share/info /usr/share/man/man1 && \
	\
# Install run-time libraries which are used for OpenOCD
apk --no-cache add libusb libftdi1 libgpiod hidapi \
	\
# Install GDB
gdb-multiarch && \
	\
# remove some unnecessary/temporary files (needed?!)
rm -fr /var/cache/apk/* /tmp/*

