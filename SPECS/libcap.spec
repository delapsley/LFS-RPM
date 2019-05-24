#TARBALL:	https://www.kernel.org/pub/linux/libs/security/linux-privs/libcap2/libcap-2.26.tar.xz
#MD5SUM:	968ac4d42a1a71754313527be2ab5df3;SOURCES/libcap-2.26.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Libcap package implements the user-space interfaces to the POSIX 1003.1e
Name:		libcap
Version:	2.26
Release:	1
License:	GPLv2
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Libcap package implements the user-space interfaces to the POSIX 1003.1e
capabilities available in Linux kernels. These capabilities are a partitioning
of the all powerful root privilege into a set of distinct privileges.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	sed -i '/install.*STALIBNAME/d' libcap/Makefile
%build
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} RAISE_SETFCAP=no lib=lib prefix=%_prefix install
	chmod -v 755 %{buildroot}%{_libdir}/libcap.so.2.26
	install -vdm 755 %{buildroot}/lib
	mv -v %{buildroot}/usr/lib/libcap.so.* %{buildroot}/lib
	ln -sfv ../../lib/$(readlink %{buildroot}/usr/lib/libcap.so) %{buildroot}/usr/lib/libcap.so
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 License %{buildroot}/usr/share/licenses/%{name}/LICENSE
#-----------------------------------------------------------------------------
#	Create file list
#	rm  %{buildroot}%{_infodir}/dir
	find %{buildroot} -name '*.la' -delete
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
	sed -i '/man\/man/d' filelist.rpm
	sed -i '/\/usr\/share\/info/d' filelist.rpm
#-----------------------------------------------------------------------------
%files -f filelist.rpm
	%defattr(-,root,root)
	%{_mandir}/man1/*.gz
	%{_mandir}/man3/*.gz
	%{_mandir}/man8/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Wed Apr 03 2019 baho-utot <baho-utot@columbus.rr.com> 2.26-1
-	Update
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 2.25-1
-	Initial build.	First version
