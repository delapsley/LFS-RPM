#TARBALL:	https://www.kernel.org/pub/linux/utils/net/iproute2/iproute2-4.20.0.tar.xz
#MD5SUM:	f3dab4c812812bbb5873cb90f471bcbf;SOURCES/iproute2-4.20.0.tar.xz
#-----------------------------------------------------------------------------
Summary:	The IPRoute2 package contains programs for basic and advanced IPV4-based networking.
Name:		iproute2
Version:	4.20.0
Release:	1
License:	GPLv2
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	https://www.kernel.org/pub/linux/utils/net/iproute2/%{NAME}-%{VERSION}.tar.xz
Requires:	filesystem
%description
The IPRoute2 package contains programs for basic and advanced IPV4-based networking.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	sed -i /ARPD/d Makefile
	rm -fv man/man8/arpd.8
	sed -i 's/m_ipt.o//' tc/Makefile
%build
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot}  DOCDIR=%{_docdir}/%{NAME}-%{VERSION} install
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
	%{_mandir}/man3/*
	%{_mandir}/man7/*
	%{_mandir}/man8/*
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 4.20.0-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 4.15.0-1
-	Initial build.	First version
