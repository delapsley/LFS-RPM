#TARBALL:	https://prdownloads.sourceforge.net/expat/expat-2.2.6.tar.bz2
#MD5SUM:	ca047ae951b40020ac831c28859161b2;SOURCES/expat-2.2.6.tar.bz2
#-----------------------------------------------------------------------------
Summary:	The Expat package contains a stream oriented C library for parsing XML.
Name:		expat
Version:	2.2.6
Release:	1
License:	Other
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://prdownloads.sourceforge.net/expat/%{name}-%{version}.tar.bz2
Requires:	filesystem
%description
The Expat package contains a stream oriented C library for parsing XML.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	sed -i 's|usr/bin/env |bin/|' run.sh.in
%build
	./configure \
		--prefix=%{_prefix} \
		--disable-static \
		--docdir=%{_docdir}/%{name}-%{version}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -v -dm755 %{buildroot}%{_docdir}/%{name}-%{version}
	install -v -m644 doc/*.{html,png,css} %{buildroot}%{_docdir}/%{name}-%{version}
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
	%{_mandir}/man1/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 2.2.6-1
-	Update for LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 2.2.5-1
-	Initial build.	First version
