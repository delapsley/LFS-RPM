%global debug_package %{nil}
#-----------------------------------------------------------------------------
Summary:	Meta package for LFS Base installation
Name:		base
Version:	8.4
Release:	1
License:	None
URL:		None
Group:		LFS/Base
Vendor:	Elizabeth
#
#	LFS Chapter 6
#
Requires:	acl
Requires:	attr
Requires:	autoconf
Requires:	automake
Requires:	bash
Requires:	bc
Requires:	binutils
Requires:	bison
Requires:	bzip2
Requires:	check
Requires:	coreutils
Requires:	diffutils
Requires:	e2fsprogs
Requires:	eudev
Requires:	expat
Requires:	file
Requires:	filesystem
Requires:	findutils
Requires:	flex
Requires:	gawk
Requires:	gcc
Requires:	gdbm
Requires:	gettext
Requires:	glibc
Requires:	gmp
Requires:	gperf
Requires:	grep
Requires:	groff
Requires:	grub
Requires:	gzip
Requires:	iana-etc
Requires:	inetutils
Requires:	intltool
Requires:	iproute2
Requires:	kbd
Requires:	kmod
Requires:	less
Requires:	lfs-bootscripts
Requires:	libcap
Requires:	libelf
Requires:	libffi
Requires:	libpipeline
Requires:	libtool
Requires:	linux
Requires:	linux-api-headers
Requires:	m4
Requires:	make
Requires:	man-db
Requires:	man-pages
Requires:	meson
Requires:	mpc
Requires:	mpfr
Requires:	ncurses
Requires:	ninja
Requires:	openssl
Requires:	patch
Requires:	perl
Requires:	pkg-config
Requires:	procps-ng
Requires:	psmisc
Requires:	python3
Requires:	readline
Requires:	sed
Requires:	shadow
Requires:	sysklogd
Requires:	sysvinit
Requires:	tar
Requires:	texinfo
Requires:	tzdata
Requires:	util-linux
Requires:	vim
Requires:	XML-Parser
Requires:	xz
Requires:	zlib
#	ADDONS:
Requires:	cpio
Requires:	mkinitramfs
Requires:	popt
Requires:	python2
Requires:	rpm
Requires:	wget
Requires:	firmware-radeon
Requires:	firmware-realtek
Requires:	firmware-amd-ucode
%description
Summary:	Meta package for LFS Base installation
#-----------------------------------------------------------------------------
%prep
%build
%install
%files
%defattr(-,lfs,lfs)
#-----------------------------------------------------------------------------
%changelog
*	Mon Apr 29 2019 baho-utot <baho-utot@columbus.rr.com> 8.4-1
-	LFS-8.4
*	Mon Oct 01 2018 baho-utot <baho-utot@columbus.rr.com> 8.2-1
-	LFS-8.2
