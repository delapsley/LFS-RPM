#TARBALL:	http://ftp.gnu.org/gnu/automake/automake-1.16.1.tar.xz
#MD5SUM:	53f38e7591fa57c3d2cee682be668e5b;SOURCES/automake-1.16.1.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Automake package contains programs for generating Makefiles for use with Autoconf
Name:		automake
Version:	1.16.1
Release:	1
License:	GPLv2
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/automake/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Automake package contains programs for generating Makefiles for use with Autoconf
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--docdir=%{_docdir}/%{NAME}-%{VERSION}
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
	%{_infodir}/*.gz
	%{_mandir}/man1/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 1.16.1-1
-	Update for LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 1.15.1-1
-	Initial build.	First version
