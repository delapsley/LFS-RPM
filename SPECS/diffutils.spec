#TARBALL:	http://ftp.gnu.org/gnu/diffutils/diffutils-3.7.tar.xz
#MD5SUM:	4824adc0e95dbbf11dfbdfaad6a1e461;SOURCES/diffutils-3.7.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Diffutils package contains programs that show the differences between files or directories.
Name:		diffutils
Version:	3.7
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/diffutils/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Diffutils package contains programs that show the differences between files or directories.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
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
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 3.7-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 3.6-1
-	Initial build.	First version
