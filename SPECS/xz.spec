#TARBALL:	http://tukaani.org/xz/xz-5.2.4.tar.xz
#MD5SUM:	003e4d0b1b1899fc6e3000b24feddf7c;SOURCES/xz-5.2.4.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Xz package contains programs for compressing and decompressing files
Name:		xz
Version:	5.2.4
Release:	1
License:	GPL
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://tukaani.org/xz/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Xz package contains programs for compressing and decompressing files.
It provides capabilities for the lzma and the newer xz compression formats.
Compressing text files with xz yields a better compression percentage than
with the traditional gzip or bzip2 commands.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--disable-static \
		--docdir=%{_docdir}/%{NAME}-%{VERSION}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	install -vdm 755 %{buildroot}/lib
	mv -v   %{buildroot}%{_bindir}/{lzma,unlzma,lzcat,xz,unxz,xzcat} %{buildroot}/bin
	mv -v %{buildroot}%{_libdir}/liblzma.so.* %{buildroot}/lib
	ln -svf ../../lib/$(readlink %{buildroot}%{_libdir}/liblzma.so) %{buildroot}%{_libdir}/liblzma.so
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
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 5.2.4-1
-	Update for LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 5.2.3-1
-	Initial build.	First version
