#TARBALL:	https://www.python.org/ftp/python/2.7.15/Python-2.7.15.tar.xz
#MD5SUM:	a80ae3cc478460b922242f43a1b4094d;SOURCES/Python-2.7.15.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Python 2 package contains the Python development environment.
Name:		python2
Version:	2.7.15
Release:	1
License:	Any
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	Python-%{VERSION}.tar.xz
Requires:	filesystem
%description
The Python 2 package contains the Python development environment.
This is useful for object-oriented programming, writing scripts,
prototyping large programs or developing entire applications.
#-----------------------------------------------------------------------------
%prep
cd %{_builddir}
%setup -q -n "Python-%{VERSION}"
#	%%setup -q -T -D -a 1  -n Python-%{VERSION}
%build
	./configure --prefix=%{_prefix} \
            --enable-shared \
            --with-system-expat \
            --with-system-ffi \
            --with-ensurepip=yes \
            --enable-unicode=ucs4
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	chmod -v 755 %{buildroot}/usr/lib/libpython2.7.so.1.0
	rm %{buildroot}%{_libdir}/python2.7/cgi.py
	rm '%{buildroot}/usr/lib/python2.7/site-packages/setuptools/command/launcher manifest.xml'
	rm "%{buildroot}/usr/lib/python2.7/site-packages/setuptools/script (dev).tmpl"
#-----------------------------------------------------------------------------
#	Copy license/copying file 
	install -D -m644 LICENSE %{buildroot}/usr/share/licenses/%{name}/LICENSE
	rm %{buildroot}/usr/bin/2to3
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
*	Wed Sep 26 2018 baho-utot <baho-utot@columbus.rr.com> python2-2.7.14-1
-	Initial build.	First version
