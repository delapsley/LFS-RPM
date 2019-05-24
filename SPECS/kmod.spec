#TARBALL:	https://www.kernel.org/pub/linux/utils/kernel/kmod/kmod-26.tar.xz
#MD5SUM:	1129c243199bdd7db01b55a61aa19601;SOURCES/kmod-26.tar.xz
#-----------------------------------------------------------------------------
Summary:	The Kmod package contains libraries and utilities for loading kernel modules
Name:		kmod
Version:	26
Release:	1
License:	GPLv2.1
URL:		Any
Group:		LFS/Base
Vendor:	Elizabeth
Source0:	https://www.kernel.org/pub/linux/utils/kernel/kmod/%{name}-%{version}.tar.xz
Requires:	filesystem
%description
The Kmod package contains libraries and utilities for loading kernel modules
#-----------------------------------------------------------------------------
%prep
%setup -q -n %{NAME}-%{VERSION}
%build
	./configure \
		--prefix=%{_prefix} \
		--bindir=/bin \
		--sysconfdir=/etc \
		--with-rootlibdir=/lib \
		--with-xz \
		--with-zlib
	make %{?_smp_mflags}
%install
	make DESTDIR=%{buildroot} install
	install -vdm 755 %{buildroot}/bin
	install -vdm 755 %{buildroot}/sbin
	for target in depmod insmod lsmod modinfo modprobe rmmod; do
		ln -sfv ../bin/kmod %{buildroot}/sbin/$target
	done
	ln -sfv kmod %{buildroot}/bin/lsmod
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
	%{_mandir}/man5/*.gz
	%{_mandir}/man8/*.gz
#-----------------------------------------------------------------------------
%changelog
*	Fri Apr 05 2019 baho-utot <baho-utot@columbus.rr.com> 26-1
-	Update for LFS-8.4
*	Tue Jan 09 2018 baho-utot <baho-utot@columbus.rr.com> 25-1
-	Initial build.	First version
