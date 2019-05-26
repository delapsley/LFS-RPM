#TARBALL:	http://ftp.gnu.org/gnu/gawk/gawk-4.2.1.tar.xz
#MD5SUM:	95cf553f50ec9f386b5dfcd67f30180a;SOURCES/gawk-4.2.1.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Gawk package contains programs for manipulating text files.
Name:		gawk
Version:	4.2.1
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/gawk/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Gawk package contains programs for manipulating text files.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	sed -i 's/extras//' Makefile.in
%build
	./configure --prefix=%{_prefix}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}%{_docdir}/%{NAME}-%{VERSION}
	cp -v doc/{awkforai.txt,*.{eps,pdf,jpg}} %{buildroot}%{_docdir}/%{NAME}-%{VERSION}
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
	%{_mandir}/man3/*
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 4.2.1-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 4.2.0-1
-	Initial build.	First version
