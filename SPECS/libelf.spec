#TARBALL:	https://sourceware.org/ftp/elfutils/0.176/elfutils-0.176.tar.bz2
#MD5SUM:	077e4f49320cad82bf17a997068b1db9;SOURCES/elfutils-0.176.tar.bz2
#-----------------------------------------------------------------------------
Summary:	The elfutils package contains a set of utilities and libraries for handling ELF files
Name:		libelf
Version:	0.176
Release:	1
License:	GPLv3
URL:		https://sourceware.org/ftp/elfutils
Group:		LFS/BASE
Vendor:	Elizabeth
Source0:	elfutils-%{version}.tar.bz2
Requires:	filesystem
%description
The elfutils package contains a set of utilities and libraries for handling ELF
(Executable and Linkable Format) files.
#-----------------------------------------------------------------------------
%prep
%setup -q -n elfutils-%{version}
%build
	./configure \
		--prefix=%{_prefix}
	make %{?_smp_mflags}
%install
#	make DESTDIR=%{buildroot} install
	make DESTDIR=%{buildroot} -C libelf install
	install -vDm644 config/libelf.pc %{buildroot}%{_libdir}/pkgconfig/libelf.pc
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
#-----------------------------------------------------------------------------
%changelog
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 0.176-1
-	Update for LFS-8.4
*	Mon Jan 01 2018 baho-utot <baho-utot@columbus.rr.com> 0.170-1
-	LFS-8.1
