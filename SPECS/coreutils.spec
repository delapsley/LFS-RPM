%global _default_patch_fuzz 2
#TARBALL:	http://ftp.gnu.org/gnu/coreutils/coreutils-8.30.tar.xz
#MD5SUM:	ab06d68949758971fe744db66b572816;SOURCES/coreutils-8.30.tar.xz
#TARBALL:	http://www.linuxfromscratch.org/patches/lfs/8.4/coreutils-8.30-i18n-1.patch
#MD5SUM:	a9404fb575dfd5514f3c8f4120f9ca7d;SOURCES/coreutils-8.30-i18n-1.patch
#-----------------------------------------------------------------------------
Summary:	The Coreutils package contains utilities for showing and setting the basic system characteristics.
Name:		coreutils
Version:	8.30
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source:	%{name}-%{version}.tar.xz
Patch0:	coreutils-8.30-i18n-1.patch
Requires:	filesystem
%description
The Coreutils package contains utilities for showing and setting the basic system characteristics.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%patch0 -p1
sed -i '/test.lock/s/^/#/' gnulib-tests/gnulib.mk
%build
	autoreconf -fiv
	FORCE_UNSAFE_CONFIGURE=1 \
	./configure \
		--prefix=%{_prefix} \
		--enable-no-install-program=kill,uptime
	FORCE_UNSAFE_CONFIGURE=1 make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	install -vdm 755 %{buildroot}%{_sbindir}
	install -vdm 755 %{buildroot}%{_mandir}/man8
	mv -v %{buildroot}%{_bindir}/{cat,chgrp,chmod,chown,cp,date,dd,df,echo} %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/{false,ln,ls,mkdir,mknod,mv,pwd,rm} %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/{rmdir,stty,sync,true,uname} %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/chroot %{buildroot}%{_sbindir}
	mv -v %{buildroot}%{_mandir}/man1/chroot.1 %{buildroot}%{_mandir}/man8/chroot.8
	sed -i s/\"1\"/\"8\"/1 %{buildroot}%{_mandir}/man8/chroot.8
	mv -v %{buildroot}%{_bindir}/{head,sleep,nice} %{buildroot}/bin
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 COPYING %{buildroot}/usr/share/licenses/%{name}/LICENSE
#-----------------------------------------------------------------------------
#	Create file list
	rm  %{buildroot}%{_infodir}/dir
	find %{buildroot} -name '*.la' -delete
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
	sed -i '/man\/man/d' filelist.rpm
	sed -i '/\/usr\/share\/info/d' filelist.rpm
#-----------------------------------------------------------------------------
%files -f filelist.rpm
	%defattr(-,root,root)
	%{_infodir}/*
	%{_mandir}/man1/*
	%{_mandir}/man8/*
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 8.30-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 8.29-1
-	Initial build.	First version
