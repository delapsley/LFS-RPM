#TARBALL:	http://download.savannah.gnu.org/releases/acl/acl-2.2.53.tar.gz
#MD5SUM:	007aabf1dbb550bcddde52a244cd1070;SOURCES/acl-2.2.53.tar.gz
#-----------------------------------------------------------------------------
Summary:	The Acl package contains utilities to administer Access Control Lists
Name:		acl
Version:	2.2.53
Release:	1
License:	GPLv2
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://download.savannah.gnu.org/releases/%{name}/%{name}-%{version}.tar.gz
Requires:	filesystem
%description
The Acl package contains utilities to administer Access Control Lists, which are
used to define more fine-grained discretionary access rights for files and directories.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--bindir=/bin \
		--disable-static \
		--libexecdir=%_libdir \
		--docdir=%{_docdir}/%{NAME}-%{VERSION}
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/lib
	install -vdm 755 %{buildroot}/usr/lib
	mv -v %{buildroot}/usr/lib/libacl.so.* %{buildroot}/lib
	ln -sfv ../../lib/$(readlink %{buildroot}/usr/lib/libacl.so) %{buildroot}/usr/lib/libacl.so
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 doc/COPYING %{buildroot}/usr/share/licenses/%{name}/LICENSE
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
	%{_mandir}/man3/*
	%{_mandir}/man5/*
#-----------------------------------------------------------------------------
%changelog
*	Wed Apr 03 2019 baho-utot <baho-utot@columbus.rr.com> 2.2.53-1
-	update
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 2.2.52-1
-	Initial build.	First version
