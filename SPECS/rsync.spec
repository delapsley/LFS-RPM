#TARBALL:	https://www.samba.org/ftp/rsync/src/rsync-3.1.3.tar.gz
#MD5SUM:	1581a588fde9d89f6bc6201e8129afaf;SOURCES/rsync-3.1.3.tar.gz
#-----------------------------------------------------------------------------
Summary:	The rsync package contains the rsync utility.
Name:		rsync
Version:	3.1.3
Release:	1
License:	GPLv3
URL:		https://rsync.samba.org
Group:		LFS/Base
Vendor:	Elizabeth
#Requires:	popt >= 1.16
Source0:	https://www.samba.org/ftp/rsync/src/rsync-%{version}.tar.gz
%description	
The rsync package contains the rsync utility.
This is useful for synchronizing large file archives over a network.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--without-included-zlib \
		--with-included-popt=no
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
#-----------------------------------------------------------------------------
#	Copy license/copying file
#	install -D -m644 LICENSE %{buildroot}/usr/share/licenses/%{name}/LICENSE
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
	%{_mandir}/man5/*
#-----------------------------------------------------------------------------
%changelog
*	Mon Feb 04 2019 baho-utot <baho-utot@columbus.rr.com> 3.1.3-1
-	Initial build.	First version
