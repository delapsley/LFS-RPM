#TARBALL:	http://ftp.gnu.org/gnu/gzip/gzip-1.10.tar.xz
#MD5SUM:	691b1221694c3394f1c537df4eee39d3;SOURCES/gzip-1.10.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Gzip package contains programs for compressing and decompressing files.
Name:		gzip
Version:	1.10
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Gzip package contains programs for compressing and decompressing files.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	./configure --prefix=%{_prefix}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/gzip %{buildroot}/bin
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
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 1.10-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 1.9-1
-	Initial build.	First version
