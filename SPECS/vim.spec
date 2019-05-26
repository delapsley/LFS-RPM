%global __requires_exclude perl\\(getopts.pl\\)
%define __requires_exclude_from /usr/share/vim
#TARBALL:	ftp://ftp.vim.org/pub/vim/unix/vim-8.1.tar.bz2
#MD5SUM:	1739a1df312305155285f0cfa6118294;SOURCES/vim-8.1.tar.bz2
#-----------------------------------------------------------------------------
Summary:	The Vim package contains a powerful text editor.
Name:		vim
Version:	8.1
Release:	1
License:	Charityware
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	%{name}-%{version}.tar.bz2
Requires:	filesystem
%description
The Vim package contains a powerful text editor.
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}81
echo '#define SYS_VIMRC_FILE "/etc/vimrc"' >> src/feature.h
%build
	./configure \
		--prefix=%{_prefix} \
		--localstatedir=/var/lib/vim \
		--with-x=no \
		--disable-gui
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/usr/share/doc/
	ln -sv ../vim/vim81/doc %{buildroot}/usr/share/doc/vim-8.1
	install -vdm 755 %{buildroot}/etc/vimrc
	cat > /etc/vimrc <<- "EOF"
		" Begin /etc/vimrc

		set nocompatible
		set backspace=2
		set mouse=r
		syntax on
		if (&term == "xterm") || (&term == "putty")
			set background=dark
		endif

		" End /etc/vimrc
	EOF
	rm -rf %{buildroot}/usr/share/info/dir
#-----------------------------------------------------------------------------
#	Copy license/copying file
	install -D -m644 README.txt %{buildroot}/usr/share/licenses/%{name}/LICENSE
#-----------------------------------------------------------------------------
#	Create file list
#	rm  %{buildroot}%{_infodir}/dir
	find %{buildroot} -name '*.la' -delete
	find "${RPM_BUILD_ROOT}" -not -type d -print > filelist.rpm
	sed -i "s|^${RPM_BUILD_ROOT}||" filelist.rpm
	sed -i '/man\/man/d' filelist.rpm
	sed -i '/man\/fr/d'  filelist.rpm
	sed -i '/man\/pl.ISO8859-2/d'  filelist.rpm
	sed -i '/man\/pl.UTF-8/d'  filelist.rpm
	sed -i '/man\/ru.UTF-8/d'  filelist.rpm
	sed -i '/man\/pl/d'  filelist.rpm
	sed -i '/man\/it.UTF-8/d'  filelist.rpm
	sed -i '/man\/ja/d'  filelist.rpm
	sed -i '/man\/it.ISO8859-1/d'  filelist.rpm
	sed -i '/man\/it/d'  filelist.rpm
	sed -i '/man\/fr.UTF-8/d'  filelist.rpm
	sed -i '/man\/ru.KOI8-R/d'  filelist.rpm
	sed -i '/man\/fr.ISO8859-1/d'  filelist.rpm
	sed -i '/\/usr\/share\/info/d' filelist.rpm
#-----------------------------------------------------------------------------
%files -f filelist.rpm
	%defattr(-,root,root)
#	%%{_infodir}/*
	%{_mandir}/man1/*
	%{_mandir}/fr.ISO8859-1/man1/*
	%{_mandir}/fr.UTF-8/man1/*
	%{_mandir}/fr/man1/*	
	%{_mandir}/it.ISO8859-1/man1/*
	%{_mandir}/it.UTF-8/man1/*
	%{_mandir}/it/man1/*
	%{_mandir}/ja/man1/*
	%{_mandir}/pl.ISO8859-2/man1/*
	%{_mandir}/pl.UTF-8/man1/*
	%{_mandir}/pl/man1/*
	%{_mandir}/ru.KOI8-R/man1/*
	%{_mandir}/ru.UTF-8/man1/*
#-----------------------------------------------------------------------------
%changelog
*	Sat Apr 06 2019 baho-utot <baho-utot@columbus.rr.com> 8.1-1
-	LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 8.0.586-1
-	Initial build.	First version
