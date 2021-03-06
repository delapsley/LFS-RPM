#TARBALL:	http://ftp.gnu.org/gnu/sed/sed-4.7.tar.xz
#MD5SUM:	777ddfd9d71dd06711fe91f0925e1573;SOURCES/sed-4.7.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Sed package contains a stream editor
Name:		sed
Version:	4.7
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/%{name}/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Sed package contains a stream editor
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	sed -i 's/usr/tools/' build-aux/help2man
	sed -i 's/testsuite.panic-tests.sh//' Makefile.in
%build
	./configure \
		--prefix=%{_prefix} \
		--bindir=/bin
	make %{?_smp_mflags}
	make %{?_smp_mflags} html
%install
	make DESTDIR=%{buildroot} install
	install -d -m755 %{buildroot}%{_docdir}/%{NAME}-%{VERSION}
	install -m644 doc/sed.html %{buildroot}%{_docdir}/%{NAME}-%{VERSION}
	rm -rf %{buildroot}/%{_infodir}
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 COPYING %{buildroot}/usr/share/licenses/%{name}/LICENSE
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
	%{_mandir}/man1/*
#-----------------------------------------------------------------------------
%changelog
*	Wed Apr 03 2019 baho-utot <baho-utot@columbus.rr.com> 4.7-1
-	Update
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 4.4-1
-	Initial build.	First version
