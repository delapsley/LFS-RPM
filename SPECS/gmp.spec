#TARBALL:	http://ftp.gnu.org/gnu/gmp/gmp-6.1.2.tar.xz
#MD5SUM:	f58fa8001d60c4c77595fbbb62b63c1d;SOURCES/gmp-6.1.2.tar.xz
#-----------------------------------------------------------------------------
Summary:	The GMP package contains math libraries.
Name:		gmp
Version:	6.1.2
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/%{name}/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The GMP package contains math libraries. These have useful functions for arbitrary precision arithmetic.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	cp -v configfsf.guess config.guess
	cp -v configfsf.sub   config.sub
%build
	./configure --prefix=%{_prefix} \
		--enable-cxx \
		--disable-static \
		--docdir=%{_docdir}/%{NAME}-%{VERSION}
	make %{?_smp_mflags}
	make %{?_smp_mflags} html
%install
	make DESTDIR=%{buildroot} install
	make DESTDIR=%{buildroot} install-html
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
#-----------------------------------------------------------------------------
%changelog
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 6.1.2-1
-	Initial build.	First version
