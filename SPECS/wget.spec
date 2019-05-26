#TARBALL:	https://ftp.gnu.org/gnu/wget/wget-1.20.1.tar.gz
#MD5SUM:	f6ebe9c7b375fc9832fb1b2028271fb7;SOURCES/wget-1.20.1.tar.gz
#-----------------------------------------------------------------------------
Summary:	The Wget package contains a utility useful for non-interactive downloading of files from the Web. 
Name:		wget
Version:	1.20.1
Release:	1
License:	Any
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.gz
Requires:	filesystem
%description
The Wget package contains a utility useful for non-interactive downloading of files from the Web. 
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--sysconfdir=/etc \
		--with-ssl=openssl \
		--disable-rpath
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
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
%post
	pushd /usr/share/info
	rm -v dir
	for f in *; do install-info $f dir 2>/dev/null; done
	popd
%postun
	pushd /usr/share/info
	rm -v dir
	for f in *; do install-info $f dir 2>/dev/null; done
	popd
#-----------------------------------------------------------------------------
%changelog
*	Sun Apr 07 2019 baho-utot <baho-utot@columbus.rr.com> 1.20.1-1
-	BLFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 1.19.1-1
-	Initial build.	First version
