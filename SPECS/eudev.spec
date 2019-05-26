#TARBALL:	https://dev.gentoo.org/~blueness/eudev/eudev-3.2.7.tar.gz
#MD5SUM:	c75d99910c1791dd9430d26ab76059c0;SOURCES/eudev-3.2.7.tar.gz
#TARBALL:	http://anduin.linuxfromscratch.org/LFS/udev-lfs-20171102.tar.bz2
#MD5SUM:	d92afb0c6e8e616792068ee4737b0d24
#-----------------------------------------------------------------------------
Summary:	The Eudev package contains programs for dynamic creation of device nodes.
Name:		eudev
Version:	3.2.7
Release:	1
License:	GPLv2
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.gz
Source1:	udev-lfs-20171102.tar.bz2
Requires:	filesystem
%description
The Eudev package contains programs for dynamic creation of device nodes.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%setup -T -D -a 1
	cat > config.cache <<- "EOF"
		HAVE_BLKID=1
		BLKID_LIBS="-lblkid"
		BLKID_CFLAGS="-I/tools/include"
	EOF
%build
	./configure \
		--prefix=%{_prefix} \
		--bindir=/sbin \
		--sbindir=/sbin \
		--libdir=%{_libdir} \
		--sysconfdir=/etc \
		--libexecdir=/lib \
		--with-rootprefix= \
		--with-rootlibdir=/lib \
		--enable-manpages \
		--disable-static \
		--config-cache
	LIBRARY_PATH=/tools/lib make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} LD_LIBRARY_PATH=/tools/lib install
	make -f udev-lfs-20171102/Makefile.lfs DESTDIR=%{buildroot} install
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 COPYING %{buildroot}/usr/share/licenses/%{name}/LICENSE
#-----------------------------------------------------------------------------
#	rm  %{buildroot}%{_infodir}/dir
	find %{buildroot} -name '*.la' -delete
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
	sed -i '/man\/man/d' filelist.rpm
	sed -i '/\/usr\/share\/info/d' filelist.rpm	
%post
	LD_LIBRARY_PATH=/tools/lib udevadm hwdb --update
#-----------------------------------------------------------------------------
%files -f filelist.rpm
	%defattr(-,root,root)
#	%%{_infodir}/*
	%{_mandir}/man5/*
	%{_mandir}/man7/*
	%{_mandir}/man8/*
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 3.2.7-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 3.2.5-1
-	Initial build.	First version
