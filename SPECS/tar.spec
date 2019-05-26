#TARBALL:	http://ftp.gnu.org/gnu/tar/tar-1.31.tar.xz
#MD5SUM:	bc9a89da1185ceb2210de12552c43ce2;SOURCES/tar-1.31.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Tar package contains an archiving program.
Name:		tar
Version:	1.31
Release:	1
License:	GPLv3
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Tar package contains an archiving program.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
sed -i 's/abort.*/FALLTHROUGH;/' src/extract.c
%build
	FORCE_UNSAFE_CONFIGURE=1 \
	./configure \
		--prefix=%{_prefix} \
		--bindir=/bin
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	make -C doc DESTDIR=%{buildroot} install-html docdir=%{_docdir}/%{NAME}-%{VERSION}
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
	%{_mandir}/man1/*
	%{_mandir}/man8/*

#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 1.31-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 1.30-1
-	Initial build.	First version
