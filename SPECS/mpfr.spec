#TARBALL:	http://www.mpfr.org/mpfr-4.0.1/mpfr-4.0.2.tar.xz
#MD5SUM:	320fbc4463d4c8cb1e566929d8adc4f8;SOURCES/mpfr-4.0.2.tar.xz
#-----------------------------------------------------------------------------
Summary:	The MPFR package contains functions for multiple precision math.
Name:		mpfr
Version:	4.0.2
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://www.mpfr.org/%{name}-%{version}/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The MPFR package contains functions for multiple precision math.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--disable-static \
		--enable-thread-safe \
		--docdir=%{_docdir}/%NAME}-%{VERSION}
	make %{?_smp_mflags}
	make %{?_smp_mflags} html
%install
	make DESTDIR=%{buildroot} install
	make DESTDIR=%{buildroot} install-html
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
	%{_infodir}/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Tue Mar 26 2019 baho-utot <baho-utot@columbus.rr.com> 4.0.2-1
-	update to version 4.0.2
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 4.0.1-1
-	Initial build.	First version
