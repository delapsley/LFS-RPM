#TARBALL:	https://sourceforge.net/projects/psmisc/files/psmisc/psmisc-23.2.tar.xz
#MD5SUM:	0524258861f00be1a02d27d39d8e5e62;SOURCES/psmisc-23.2.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Psmisc package contains programs for displaying information about running processes.
Name:		psmisc
Version:	23.2
Release:	1
License:	GPLv2
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	https://sourceforge.net/projects/psmisc/files/%{name}/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Psmisc package contains programs for displaying information about running processes.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/fuser   %{buildroot}/bin
	mv -v %{buildroot}%{_bindir}/killall %{buildroot}/bin
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
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 23.2-1
-	Update for LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 23.1-1
-	Initial build.	First version
