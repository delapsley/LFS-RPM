#!/bin/bash
#-----------------------------------------------------------------------------
#	Title: ch6.sh
#	Date: 2019-03-14
#	Version: 1.0
#	Author: baho-utot@columbus.rr.com
#	Options:
#-----------------------------------------------------------------------------
#	Copyright 2019 Baho Utot
#-----------------------------------------------------------------------------
#	This program is free software: you can redistribute it and/or modify
#	it under the terms of the GNU General Public License as published by
#	the Free Software Foundation, either version 3 of the License, or
#	(at your option) any later version.

#	This program is distributed in the hope that it will be useful,
#	but WITHOUT ANY WARRANTY; without even the implied warranty of
#	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#	GNU General Public License for more details.

#	You should have received a copy of the GNU General Public License
#	along with this program.  If not, see <https://www.gnu.org/licenses/>.
#-----------------------------------------------------------------------------
#	Dedicated to Elizabeth my cat of 20 years, Euthanasia on 2019-05-16
#-----------------------------------------------------------------------------
set -o errexit	# exit if error...insurance ;)
set -o nounset	# exit if variable not initalized
set +h			# disable hashall
#-----------------------------------------------------------------------------
#	Master variables
PRGNAME=${0##*/}		# script name minus the path
TOPDIR=${PWD}			# parent directory
PARENT=/usr/src/LFS-RPM	# rpm build directory
LOGS=LOGS			# build logs directory
INFOS=INFO			# rpm info log directory
SPECS=SPECS			# rpm spec file directory
PROVIDES=PROVIDES		# rpm provides log directory
REQUIRES=REQUIRES		# rpm requires log directory
RPMS=RPMS			# rpm binary package directory
LOGPATH=${TOPDIR}/LOGS	# path to log directory
LC_ALL=POSIX
PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin
export LC_ALL PATH
#-----------------------------------------------------------------------------
#	GLOBALS
RPM_NAME=""
RPM_VERSION=""
RPM_RELEASE=""
RPM_SPEC=""
RPM_INSTALLED=""
RPM_ARCH=""
RPM_BINARY=""
RPM_PACKAGE=""
RPM_EXISTS=""
RPM_TARBALLS=""
RPM_MD5SUMS=""
#-----------------------------------------------------------------------------
#	Common support functions
function die {
	local _red="\\033[1;31m"
	local _normal="\\033[0;39m"
	[ -n "$*" ] && printf "${_red}$*${_normal}\n"
	false
	exit 1
}
function msg {
	printf "%s\n" "${1}"
	return
}
function msg_line {
	printf "%s" "${1}"
	return
}
function msg_failure {
	local _red="\\033[1;31m"
	local _normal="\\033[0;39m"
	printf "${_red}%s${_normal}\n" "FAILURE"
	exit 2
}
function msg_success {
	local _green="\\033[1;32m"
	local _normal="\\033[0;39m"
	printf "${_green}%s${_normal}\n" "SUCCESS"
	return
}
function msg_log {
	printf "\n%s\n\n" "${1}" >> ${_logfile} 2>&1
	return
}
function end_run {
	local _green="\\033[1;32m"
	local _normal="\\033[0;39m"
	printf "${_green}%s${_normal}\n" "Run Complete"
	return
}
#-----------------------------------------------------------------------------
#	Functions
function _build {
	local i=""
	local _log="${LOGS}/${RPM_NAME}"
	> ${_log}
	> ${INFOS}/${RPM_NAME}
	> ${PROVIDES}/${RPM_NAME}
	> ${REQUIRES}/${RPM_NAME}
	rm -rf BUILD BUILDROOT
	msg_line "Building: ${RPM_NAME}: "
	_md5sum
	rpmbuild -ba ${RPM_SPEC} >> ${_log} 2>&1 && msg_success || msg_failure
	_status
	[ "F" == ${RPM_EXISTS} ] && die "ERROR: Binary Missing: ${RPM_BINARY}"
	rpm -qilp		${RPMS}/${RPM_ARCH}/${RPM_BINARY} > ${INFOS}/${RPM_NAME}	2>&1 || true
	rpm -qp --provides	${RPMS}/${RPM_ARCH}/${RPM_BINARY} > ${PROVIDES}/${RPM_NAME}	2>&1 || true
	rpm -qp --requires	${RPMS}/${RPM_ARCH}/${RPM_BINARY} > ${REQUIRES}/${RPM_NAME}	2>&1 || true
	return
}
function _params {
	local i=""
	RPM_NAME=""
	RPM_VERSION=""
	RPM_RELEASE=""
	RPM_SPEC=""
	RPM_INSTALLED=""
	RPM_ARCH=""
	RPM_BINARY=""
	RPM_PACKAGE=""
	RPM_EXISTS=""
	RPM_TARBALLS=""
	RPM_MD5SUMS=""
	RPM_SPEC=${1}
	RPM_ARCH=$(rpm --eval %_arch)
	if [ -e ${RPM_SPEC} ]; then
		while  read i; do
			i=$(echo ${i} | tr -d '[:cntrl:][:space:]')
			case ${i} in
				Name:*)	RPM_NAME=${i##Name:}			;;
				Version:*)	RPM_VERSION=${i##Version:}		;;
				Release:*)	RPM_RELEASE=${i##Release:}		;;
				?TARBALL:*)	RPM_TARBALLS+="${i##?TARBALL:} "	;;
				?MD5SUM:*)	RPM_MD5SUMS+="${i##?MD5SUM:} "	;;
				*)	;;
			esac
		done < ${RPM_SPEC}
		#	remove trailing whitespace
		RPM_TARBALLS=${RPM_TARBALLS## }
		RPM_MD5SUMS=${RPM_MD5SUMS## }
	else
		die "ERROR: ${RPM_SPEC}: does not exist"
	fi
	RPM_BINARY="${RPM_NAME}-${RPM_VERSION}-${RPM_RELEASE}.${RPM_ARCH}.rpm"
	RPM_PACKAGE=${RPM_BINARY%.*}
	_status
	return
}
function _install {
	local _log="${LOGS}/${RPM_NAME}"
	_status
	[ "F" == ${RPM_EXISTS} ] && die "ERROR: Binary Missing: ${RPM_BINARY}"
	[ "T" == ${RPM_INSTALLED} ] && return
	msg_line "Installing: ${RPM_BINARY}: "
	rpm -Uvh --nodeps "${RPMS}/${RPM_ARCH}/${RPM_BINARY}" >> "${_log}" 2>&1  && msg_success || msg_failure
	return
}
function _status {
	[ -e "${RPMS}/${RPM_ARCH}/${RPM_BINARY}" ] && RPM_EXISTS="T" || RPM_EXISTS="F"
	[ "${RPM_PACKAGE}" == "$(rpm -q "$RPM_PACKAGE")" ] && RPM_INSTALLED="T" || RPM_INSTALLED="F"
	return
}
function _print {
	msg "Status for ${RPM_BINARY}"
	msg "Spec-------->	${RPM_SPEC}"
	msg "Name-------->	${RPM_NAME}"
	msg "Version----->	${RPM_VERSION}"
	msg "Release----->	${RPM_RELEASE}"
	msg "Arch-------->	${RPM_ARCH}"
	msg "Package----->	${RPM_PACKAGE}"
	msg "Binary------>	${RPM_BINARY}"
	msg "Exists------>	${RPM_EXISTS}"
	msg "Installed--->	${RPM_INSTALLED}"
	for i in ${RPM_TARBALLS}; do msg "Tarball----->	${i}";done
	for i in ${RPM_MD5SUMS};  do msg "MD5SUM------>	${i}";done
	return
}
function _md5sum {
	local i=""
	[ -z "${RPM_TARBALLS}" ] && return
	> SOURCES/"MD5SUM"
	for i in ${RPM_MD5SUMS}; do printf "%s\n" "$(echo ${i} | tr ";" " ")" >> SOURCES/"MD5SUM";done
	md5sum -c SOURCES/"MD5SUM" > /dev/null 2>&1 || die "Source checksum error: ${RPM_SPEC}"
	return
}
function _symlinks {
	msg_line "Installing Essential Files and Symlinks: "
	_log="${LOGS}/symlinks"
	> ${_log}
	ln -vsf /tools/bin/{bash,cat,chmod,dd,echo,ln,mkdir,pwd,rm,stty,touch} /bin  >> "${_log}" 2>&1
	ln -vsf /tools/bin/{env,install,perl,printf} /usr/bin >> "${_log}" 2>&1
	ln -vsf /tools/lib/libgcc_s.so{,.1} /usr/lib >> "${_log}" 2>&1
	ln -vsf /tools/lib/libstdc++.{a,so{,.6}} /usr/lib >> "${_log}" 2>&1
	install -vdm755 /usr/lib/pkgconfig >> "${_log}" 2>&1
	ln -vsf bash /bin/sh >> "${_log}" 2>&1
	msg_success
	return
}
function _glibc {
	ln -sf /tools/lib/gcc /usr/lib
	ln -sf ../lib/ld-linux-x86-64.so.2 /lib64
	ln -sf ../lib/ld-linux-x86-64.so.2 /lib64/ld-lsb-x86-64.so.3
	rm -f /usr/include/limits.h
	_build
	_install
	/sbin/locale-gen
	return
}
function _adjust {
	msg_line " Adjusting tool chain: "
	_log="${LOGS}/adjust"
	> "${_log}"
	mv -v /tools/bin/{ld,ld-old} >> "${_log}" 2>&1
	mv -v /tools/$(uname -m)-pc-linux-gnu/bin/{ld,ld-old} >> "${_log}" 2>&1
	mv -v /tools/bin/{ld-new,ld} >> "${_log}" 2>&1
	ln -sv /tools/bin/ld /tools/$(uname -m)-pc-linux-gnu/bin/ld >> "${_log}" 2>&1
	gcc -dumpspecs | sed -e 's@/tools@@g' -e '/\*startfile_prefix_spec:/{n;s@.*@/usr/lib/ @}' -e '/\*cpp:/{n;s@$@ -isystem /usr/include@}' > `dirname $(gcc --print-libgcc-file-name)`/specs
	touch ${_log}
	_log="${LOGS}/adjust.test"
	msg_line "Testing tool chain: "
	> "${_log}"
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	msg " " >> "${_log}" 2>&1
	msg "Test:	[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]" >> "${_log}" 2>&1
	readelf -l a.out | grep ': /lib' >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	msg "Test:	/usr/lib/../lib/crt1.o succeeded" >> "${_log}" 2>&1
	msg "Test:	/usr/lib/../lib/crti.o succeeded" >> "${_log}" 2>&1
	msg "Test:	/usr/lib/../lib/crtn.o succeeded" >> "${_log}" 2>&1
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	msg "Test:	#include <...> search starts here:" >> "${_log}" 2>&1
	msg "Test:	/usr/include" >> "${_log}" 2>&1
	grep -B1 '^ /usr/include' dummy.log>> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	msg "Test:	SEARCH_DIR("/usr/lib")" >> "${_log}" 2>&1
	msg "Test:	SEARCH_DIR("/lib")" >> "${_log}" 2>&1
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	msg "Test:	attempt to open /lib/libc.so.6 succeeded" >> "${_log}" 2>&1
	grep "/lib.*/libc.so.6 " dummy.log >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	msg "Test:	found ld-linux-x86-64.so.2 at /lib/ld-linux-x86-64.so.2"  >> "${_log}" 2>&1
	grep found dummy.log >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	rm -v dummy.c a.out dummy.log >> "${_log}" 2>&1
	msg_success
	touch ${_log}
	return
}
function _bc {
	ln -sf /tools/lib/libncursesw.so.6 /usr/lib/libncursesw.so.6
	ln -sf libncursesw.so.6 /usr/lib/libncurses.so
	_build
	_install
	return
}
function _gcc {
	_build
	_install
	_log="${LOGS}/gcc.test"
	msg_line " Testing ${i}: "
	_log="${LOGS}/gcc.test"
	> "${_log}"
	echo 'int main(){}' > dummy.c
	cc dummy.c -v -Wl,--verbose &> dummy.log
	msg " " >> "${_log}" 2>&1
	readelf -l a.out | grep ': /lib' >> "${_log}" 2>&1
	msg "Test:" >> "${_log}" 2>&1
	msg "[Requesting program interpreter: /lib64/ld-linux-x86-64.so.2]" >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	grep -o '/usr/lib.*/crt[1in].*succeeded' dummy.log >> "${_log}" 2>&1
	msg "Test:" >> "${_log}" 2>&1
	msg "/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.0/../../../../lib/crt1.o succeeded" >> "${_log}" 2>&1
	msg "/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.0/../../../../lib/crti.o succeeded" >> "${_log}" 2>&1
	msg "/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.0/../../../../lib/crtn.o succeeded" >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	grep -B4 '^ /usr/include' dummy.log >> "${_log}" 2>&1
	msg "Test:" >> "${_log}" 2>&1
	msg "#include <...> search starts here:" >> "${_log}" 2>&1
	msg "/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.0/include" >> "${_log}" 2>&1
	msg "/usr/local/include" >> "${_log}" 2>&1
	msg "/usr/lib/gcc/x86_64-pc-linux-gnu/8.2.0/include-fixed" >> "${_log}" 2>&1
	msg "/usr/include" >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	grep 'SEARCH.*/usr/lib' dummy.log |sed 's|; |\n|g' >> "${_log}" 2>&1
	msg "Test:" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib64")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/usr/local/lib64")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/lib64")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/usr/lib64")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/usr/x86_64-pc-linux-gnu/lib")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/usr/local/lib")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/lib")" >> "${_log}" 2>&1
	msg "SEARCH_DIR("/usr/lib");" >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	grep "/lib.*/libc.so.6 " dummy.log >> "${_log}" 2>&1
	msg "Test:" >> "${_log}" 2>&1
	msg "attempt to open /lib/libc.so.6 succeeded" >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	grep found dummy.log >> "${_log}" 2>&1
	msg "Test:" >> "${_log}" 2>&1
	msg "found ld-linux-x86-64.so.2 at /lib/ld-linux-x86-64.so.2"  >> "${_log}" 2>&1
	msg " " >> "${_log}" 2>&1
	rm -v dummy.c a.out dummy.log >> "${_log}" 2>&1
	msg_success
	return
}
#-----------------------------------------------------------------------------
#	Main line
#	Create directories if needed
[ -e "${LOGS}" ]	||	install -vdm 755 "${LOGS}"
[ -e "${INFOS}" ]	||	install -vdm 755 "${INFOS}"
[ -e "${PROVIDES}" ]	||	install -vdm 755 "${PROVIDES}"
[ -e "${REQUIRES}" ]	||	install -vdm 755 "${REQUIRES}"
[ -e "${RPMS}" ]	||	install -vdm 755 "${RPMS}"
LIST+="filesystem "		#	6.5. Creating Directories
LIST+="symlinks "		#	6.6. Creating Essential Files and Symlinks
LIST+="linux-api-headers "	#	6.7. Linux-4.20.12 API Headers
LIST+="man-pages "		#	6.8. Man-pages-4.16 
LIST+="glibc "		#	6.9. Glibc-2.29
LIST+="tzdata "		#	6.9.2.2. Adding time zone data 
LIST+="adjust "		#	6.10. Adjusting the Toolchain
LIST+="zlib "			#	6.11. Zlib-1.2.11
LIST+="file "			#	6.12. File-5.36
LIST+="readline "		#	6.13. Readline-8.0
LIST+="m4 "			#	6.14. M4-1.4.18
LIST+="bc "			#	6.15. Bc-1.07.1
LIST+="binutils "		#	6.16. Binutils-2.32
LIST+="gmp "			#	6.17. GMP-6.1.2
LIST+="mpfr "			#	6.18. MPFR-4.0.2
LIST+="mpc "			#	6.19. MPC-1.1.0
LIST+="shadow "		#	6.20. Shadow-4.6
LIST+="gcc "			#	6.21. GCC-8.2.0
LIST+="bzip2 "		#	6.22. Bzip2-1.0.6
LIST+="pkg-config "		#	6.23. Pkg-config-0.29.2
LIST+="ncurses "		#	6.24. Ncurses-6.1
LIST+="attr "			#	6.25. Attr-2.4.48
LIST+="acl "			#	6.26. Acl-2.2.53
LIST+="libcap "		#	6.27. Libcap-2.26
LIST+="sed "			#	6.28. Sed-4.7
LIST+="psmisc "		#	6.29. Psmisc-23.2
LIST+="iana-etc "		#	6.30. Iana-Etc-2.30
LIST+="bison "		#	6.31. Bison-3.3.2
LIST+="flex "			#	6.32. Flex-2.6.4
LIST+="grep "			#	6.33. Grep-3.3
LIST+="bash "			#	6.34. Bash-5.0
LIST+="libtool "		#	6.35. Libtool-2.4.6
LIST+="gdbm "			#	6.36. GDBM-1.18.1
LIST+="gperf "		#	6.37. Gperf-3.1
LIST+="expat "		#	6.38. Expat-2.2.6
LIST+="inetutils "		#	6.39. Inetutils-1.9.4
LIST+="perl "			#	6.40. Perl-5.28.1
LIST+="XML-Parser "		#	6.41. XML::Parser-2.44
LIST+="intltool "		#	6.42. Intltool-0.51.0
LIST+="autoconf "		#	6.43. Autoconf-2.69
LIST+="automake "		#	6.44. Automake-1.16.1
LIST+="xz "			#	6.45. Xz-5.2.4
LIST+="kmod "			#	6.46. Kmod-26
LIST+="gettext "		#	6.47. Gettext-0.19.8.1
LIST+="libelf "		#	6.48. Libelf from Elfutils-0.176
LIST+="libffi "		#	6.49. Libffi-3.2.1
LIST+="openssl "		#	6.50. OpenSSL-1.1.1a
LIST+="python3 "		#	6.51. Python-3.7.2
LIST+="ninja "		#	6.52. Ninja-1.9.0
LIST+="meson "		#	6.53. Meson-0.49.2
LIST+="coreutils "		#	6.54. Coreutils-8.30
LIST+="check "		#	6.55. Check-0.12.0
LIST+="diffutils "		#	6.56. Diffutils-3.7
LIST+="gawk "			#	6.57. Gawk-4.2.1
LIST+="findutils "		#	6.58. Findutils-4.6.0
LIST+="groff "		#	6.59. Groff-1.22.4
LIST+="grub "			#	6.60. GRUB-2.02
LIST+="less "			#	6.61. Less-530
LIST+="gzip "			#	6.62. Gzip-1.10
LIST+="iproute2 "		#	6.63. IPRoute2-4.20.0
LIST+="kbd "			#	6.64. Kbd-2.0.4
LIST+="libpipeline "		#	6.65. Libpipeline-1.5.1 
LIST+="make "			#	6.66. Make-4.2.1
LIST+="patch "		#	6.67. Patch-2.7.6
LIST+="man-db "		#	6.68. Man-DB-2.8.5
LIST+="tar "			#	6.69. Tar-1.31
LIST+="texinfo "		#	6.70. Texinfo-6.5
LIST+="vim "			#	6.71. Vim-8.1
LIST+="procps-ng "		#	6.72. Procps-ng-3.3.15
LIST+="util-linux "		#	6.73. Util-linux-2.33.1
LIST+="e2fsprogs "		#	6.74. E2fsprogs-1.44.5
LIST+="sysklogd "		#	6.75. Sysklogd-1.5.1
LIST+="sysvinit "		#	6.76. Sysvinit-2.93
LIST+="eudev "		#	6.77. Eudev-3.2.7
#	Chapter 7
LIST+="lfs-bootscripts "	#	lfs-bootscripts
LIST+="cpio "			#	cpio
LIST+="mkinitramfs "		#	mkinitramfs
LIST+="linux "		#	8.3. Linux-4.20.12
#	ADDONS
LIST+="popt "			#	popt
LIST+="python2 "		#	python2
LIST+="rpm "			#	rpm
LIST+="wget "			#	wget
LIST+="firmware-radeon "	#	firmware-radeon
LIST+="firmware-realtek "	#	firmware-realtek
LIST+="firmware-amd-ucode "	#	firmware-amd-ucode
LIST+="base "			#	lfs base packages meta package
for i in ${LIST};do
	case ${i} in	
		symlinks)	_log="${LOGS}/symlinks"
				if [ -e ${_log} ]; then
					msg "Skipping: Installing Essential Files and Symlinks"
				else
					_symlinks
				fi
				;;
		glibc)		_params "${SPECS}/${i}.spec"
				if [ "T" = "${RPM_EXISTS}" ]; then
					msg "Skipping: ${i}"
				else
					_glibc
				fi
				;;
		adjust)		_log="${LOGS}/adjust"
				if [ -e ${_log} ]; then
					msg "Skipping: Adjusting tool chain"
				else
					_adjust
				fi
				;;
		bc)		_params "${SPECS}/${i}.spec"
				if [ "T" = "${RPM_EXISTS}" ]; then
					msg "Skipping: ${i}"
				else
					_bc
				fi
				;;
		gcc)		_params "${SPECS}/${i}.spec"
				if [ "T" = "${RPM_EXISTS}" ]; then
					msg "Skipping: ${i}"
				else
					_gcc
				fi
				;;
		util-linux)	_params "${SPECS}/${i}.spec"
				if [ "T" = "${RPM_EXISTS}" ]; then
					msg "Skipping: ${i}"
				else
					[ -e /usr/include/blkid ] && rm -rf /usr/include/blkid
					[ -e /usr/include/libmount ] && rm -rf /usr/include/libmount
					[ -e /usr/include/uuid ] && rm -rf /usr/include/uuid
					_build
					_install
				fi
				;;
		*)		_params "${SPECS}/${i}.spec"
				if [ "T" = "${RPM_EXISTS}" ]; then
					msg "Skipping: ${i}"
				else
					_build
					_install
				fi
				;;
		esac
done
#	update ld cache, generate locales and set user/group files
unset LIST
LIST+="/sbin/ldconfig "
LIST+="/sbin/locale-gen "
LIST+="/usr/sbin/pwconv "
LIST+="/usr/sbin/grpconv "
for i in ${LIST}; do msg_line "${i}: ";eval " ${i}";msg_success;done
#	Configure
unset LIST
LIST+="/etc/sysconfig/clock "
LIST+="/etc/passwd "
LIST+="/etc/hosts "
LIST+="/etc/hostname "
LIST+="/etc/fstab "
LIST+="/etc/sysconfig/ifconfig.eth0 "
LIST+="/etc/resolv.conf "
LIST+="/etc/lsb-release "
LIST+="/etc/sysconfig/rc.site "
for i in ${LIST}; do vim "${i}";done
end_run
