#TARBALL:	http://ftp.gnu.org/gnu/bash/bash-5.0.tar.gz
#MD5SUM:	2b44b47b905be16f45709648f671820b;SOURCES/bash-5.0.tar.gz
#-----------------------------------------------------------------------------
Summary:	The Bash package contains the Bourne-Again SHell.
Name:		bash
Version:	5.0
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/%{name}/%{name}-%{version}.tar.gz
Requires:	filesystem
%description
The Bash package contains the Bourne-Again SHell.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--docdir=%{_docdir}/%{NAME}-%{VERSION} \
		--without-bash-malloc \
		--with-installed-readline
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	mv -vf %{buildroot}%{_bindir}/bash %{buildroot}/bin
	ln -vs bash %{buildroot}/bin/sh
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
	%{_infodir}/*.gz
	%{_mandir}/man1/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 5.0-1
-	Update for LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 4.4.18-1
-	Initial build.	First version
