#TARBALL:	http://download.savannah.gnu.org/releases/attr/attr-2.4.48.tar.gz
#MD5SUM:	bc1e5cb5c96d99b24886f1f527d3bb3d;SOURCES/attr-2.4.48.tar.gz
#-----------------------------------------------------------------------------
Summary:	The attr package contains utilities to administer the extended attributes on filesystem objects.
Name:		attr
Version:	2.4.48
Release:	1
License:	GPLv2
URL:		http://savannah.nongnu.org/projects/attr
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://download.savannah.gnu.org/releases/%{name}/%{name}-%{version}.tar.gz
Requires:	filesystem
%description
The attr package contains utilities to administer the extended attributes on filesystem objects.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--bindir=/bin \
		--disable-static \
		--sysconfdir=/etc \
		--docdir=%{_docdir}/%{NAME}-%{VERSION}
		make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/lib
	install -vdm 755 %{buildroot}/usr/lib
	mv -v %{buildroot}/usr/lib/libattr.so.* %{buildroot}/lib
	ln -sfv ../../lib/$(readlink %{buildroot}/usr/lib/libattr.so) %{buildroot}/usr/lib/libattr.so
#-----------------------------------------------------------------------------
#	Copy license/copying file
#	install -D -m644 doc/COPYINGLICENSE %{buildroot}/usr/share/licenses/%{name}/LICENSE
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
	%{_mandir}/man3/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Wed Apr 03 2018 baho-utot <baho-utot@columbus.rr.com> 2.4.48-1
-	update
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 2.4.47-1
-	Initial build.	First version
