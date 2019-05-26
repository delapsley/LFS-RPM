#TARBALL:	http://www.linuxfromscratch.org/lfs/downloads/8.4/lfs-bootscripts-20180820.tar.bz2
#MD5SUM:	e08811a18356eeef524b2ed333e8cb86;SOURCES/lfs-bootscripts-20180820.tar.bz2
#-----------------------------------------------------------------------------
Summary:	The LFS-Bootscripts package contains a set of scripts to start/stop the LFS system at bootup/shutdown.
Name:		lfs-bootscripts
Version:	20180820
Release:	1
License:	None
URL:		http://www.linuxfromscratch.org
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	lfs-bootscripts-20180820.tar.bz2
Requires:	filesystem
%description
The LFS-Bootscripts package contains a set of scripts to start/stop the LFS system
at bootup/shutdown. The configuration files and procedures needed to customize the
boot process are described in the following sections.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
%install
	make DESTDIR=%{buildroot} install
#	rm  %{buildroot}/etc/sysconfig/rc.site
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
	%{_mandir}/man8/*
#-----------------------------------------------------------------------------
%changelog
*	Sun Apr 07 2019 baho-utot <baho-utot@columbus.rr.com> 20180820-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 20170626-1
-	Initial build.	First version
