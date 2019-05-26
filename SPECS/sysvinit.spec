#TARBALL:	http://download.savannah.gnu.org/releases/sysvinit/sysvinit-2.93.tar.xz
#MD5SUM:	041dbe36a5dd80b2108aff305bc10620;SOURCES/sysvinit-2.93.tar.xz
#TARBALL:	http://www.linuxfromscratch.org/patches/lfs/8.4/sysvinit-2.93-consolidated-1.patch
#MD5SUM:	aaa84675e717504d7d3da452c8c2eaf1;SOURCES/sysvinit-2.93-consolidated-1.patch
#-----------------------------------------------------------------------------
Summary:	Controls the start up, running and shutdown of the system
Name:		sysvinit
Version:	2.93
Release:	1
License:	GPLv2
URL:		http://savannah.nongnu.org/projects/sysvinit
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.xz
Patch:		%{name}-%{version}-consolidated-1.patch
Requires:	filesystem
%description
Contains programs for controlling the start up, running and
shutdown of the system
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%patch	-p1
%build
	make VERBOSE=1  %{?_smp_mflags}
%install
	make ROOT=%{buildroot} install
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 COPYRIGHT %{buildroot}/usr/share/licenses/%{name}/LICENSE
	install -D -m644 COPYING %{buildroot}/usr/share/licenses/%{name}/
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
#	%%{_infodir}/*
	%{_mandir}/man5/*
	%{_mandir}/man8/*
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 2.93-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 2.88dsf-1
-	Initial build.	First version
