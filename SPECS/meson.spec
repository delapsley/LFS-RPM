#TARBALL:	https://github.com/mesonbuild/meson/releases/download/0.49.2/meson-0.49.2.tar.gz
#MD5SUM:	0267b0871266056184c484792572c682;SOURCES/meson-0.49.2.tar.gz
#-----------------------------------------------------------------------------
Summary:	Meson is an open source build system
Name:		meson
Version:	0.49.2
Release:	1
License:	Any
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source:	%{name}-%{version}.tar.gz
Requires:	filesystem
%description
Meson is an open source build system meant to be both extremely fast, and, even more importantly, as user friendly as possible.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	python3 setup.py build
%install
	install -vdm 755 %{buildroot}/usr/lib/python3.7/site-packages/
	python3 setup.py install --root="%{buildroot}" --optimize=1 --skip-build 
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
	%{_mandir}/man1/meson.1.gz
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 0.49.2-1
-	LFS-8.4
*	Wed Jul 25 2018 baho-utot <baho-utot@columbus.rr.com> 0.44.0-1
-	Initial build.	First version
