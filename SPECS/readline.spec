#TARBALL:	http://ftp.gnu.org/gnu/readline/readline-8.0.tar.gz
#MD5SUM:	7e6c1f16aee3244a69aba6e438295ca3;SOURCES/readline-8.0.tar.gz
#-----------------------------------------------------------------------------
Summary:	The Readline package is a set of libraries that offers command-line editing and history capabilities
Name:		readline
Version:	8.0
Release:	1
License:	GPLv3
URL:		http://ftp.gnu.org/gnu/readline/%{name}-%{version}.tar.gz
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	http://ftp.gnu.org/gnu/%{name}/%{name}-%{version}.tar.gz
Requires:	filesystem
%description
The Readline package is a set of libraries that offers command-line editing and history capabilities
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
	sed -i '/MV.*old/d' Makefile.in
	sed -i '/{OLDSUFF}/c:' support/shlib-install
%build
	./configure \
		--prefix=%{_prefix} \
		--disable-static \
		--docdir=%{_mandir}/%{name}-%{version}
	make %{?_smp_mflags}  SHLIB_LIBS="-L/tools/lib -lncursesw"
%install
	make DESTDIR=%{buildroot} SHLIB_LIBS="-L/tools/lib -lncurses" install
	install -vdm 755 %{buildroot}/lib
	install -vdm 755 %{buildroot}%{_libdir}
	mv -v %{buildroot}%{_libdir}/lib{readline,history}.so.* %{buildroot}/lib
	chmod -v u+w %{buildroot}/lib/lib{readline,history}.so.*
	ln -sfv ../../lib/$(readlink %{buildroot}%{_libdir}/libreadline.so) %{buildroot}%{_libdir}/libreadline.so
	ln -sfv ../../lib/$(readlink %{buildroot}%{_libdir}/libhistory.so ) %{buildroot}%{_libdir}/libhistory.so
	#	documentation
	install -vdm 755 %{buildroot}%{_docdir}/readline-8.0
	install -v -m644 doc/*.{ps,pdf,html,dvi} %{buildroot}%{_docdir}/readline-8.0
	rm -rf %{buildroot}%{_infodir}
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
	%{_mandir}/man3/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Mon Mar 25 2019 baho-utot <baho-utot@columbus.rr.com> 8.0-1
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 7.0-1
-	Initial build.	First version
