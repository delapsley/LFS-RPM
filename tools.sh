#!/bin/bash
#-----------------------------------------------------------------------------
#	  Title: tools.sh
#	   Date: 2019-02-16
#	Version: 1.1
#	 Author: baho-utot@columbus.rr.com
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
#	Common variables
PRGNAME=${0##*/}		# script name minus the path
TOPDIR=${PWD}			# this directory
PARENT=/usr/src/LFS-RPM	# build system master directory
MKFLAGS="-j 1"		# Number of cpu to use in building pkgs default = 1
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
	printf "${_green}%s${_normal}\n" "Run Complete - ${PRGNAME}"
	return
}
#-----------------------------------------------------------------------------
#	Local functions
function _sanity {
	[ $(whoami) = "lfs" ] || die "Not running as user lfs, you should be!"
	[ -v LFS ] || die "LFS environment variable missing/not set"
	[ "/tools/bin:/bin:/usr/bin" = "${PATH}" ] || die "PATH environment variable missing/not corrrect"
	[ -v LFS_TGT ] || die "LFS_TGT environment variable missing/not set"
	[ "${HOSTTYPE}-lfs-${OSTYPE}" = "${LFS_TGT}" ] || die "LFS_TGT environment variable incorrect"
	[ -d ${LFS} ]	 || die "${LFS} directory missing"
	[ -d ${LFS}/tools ] || die "${LFS}/tools directory missing"
	[ -h /tools ] || die "tools root symlink missing"
	[ $(stat -c %U ${LFS}/tools) = "lfs" ] || die "The tools directory not owned by user lfs"
	[ ${TOPDIR} = ${LFS}${PARENT} ] || die "Not in the correct build directory"
	[ -d "${TOPDIR}/LOGS" ] || install -dm 755 "${TOPDIR}/LOGS"
	[ -d "${TOPDIR}/BUILD" ] || install -dm 755 "${TOPDIR}/BUILD"
	return
}
function do_strip {
	msg_line "Stripping file: "
		strip --strip-debug /tools/lib/* > /dev/null 2&>1 || true
		/usr/bin/strip --strip-unneeded /tools/{,s}bin/* > /dev/null 2&>1 || true
		rm -rf /tools/{,share}/{info,man,doc}
		find /tools/{lib,libexec} -name \*.la -delete
	msg_success
	return
}
function set-mkflags {
	msg_line "Setting MKFLAGS: "
		MKFLAGS="-j 1" 						# default
		MKFLAGS="-j $(getconf _NPROCESSORS_ONLN || true)"	# how many processors on this host
		[ '-j' == "${MKFLAGS}" ] && MKFLAGS="-j 2"		# set two cpu's default
		printf "%s" "${FUNCNAME}: MKFLAGS: ${MKFLAGS}: "
	msg_success
	return
}
function unpack {
	# $1 = source package name
	local tarball=${TOPDIR}/SOURCES/${1}
	msg_line "	Unpacking: ${1}: "
		[ -e ${tarball} ] || die " File not found: FAILURE"
		tar xf ${tarball} && msg_success || msg_failure
	return 0
}
function clean-build-directory {
	msg_line "Cleaning BUILD directory: "
		rm -rf ${TOPDIR}/BUILD/*
		rm -rf ${TOPDIR}/BUILDROOT/*
	msg_success
	return
}
#-----------------------------------------------------------------------------
#	Package functions
function Binutils-Pass-1 {
	#	5.4. Binutils-2.32 - Pass 1
	local pkg=binutils-2.32.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			mkdir build 
			pushd build >> /dev/null 2>&1
				msg_line "	Configure: "
					../configure --prefix=/tools \
						--with-sysroot=${LFS} \
						--with-lib-path=/tools/lib \
						--target=${LFS_TGT} \
						--disable-nls \
						--disable-werror >> ${logfile} 2>&1
				msg_success
				msg_line "	     Make: "
					make ${MKFLAGS} >> ${logfile} 2>&1
				msg_success
				msg_line "	  Install: "
					install -vdm 755 /tools/lib >> ${logfile} 2>&1
					[ "x86_64" = ${HOSTTYPE} ] && ln -sv lib /tools/lib64 >> ${logfile} 2>&1
					make install >> ${logfile} 2>&1
				msg_success
			popd > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function GCC-Pass-1 {
	#	5.5. GCC-8.2.0 - Pass 1
	local pkg=gcc-8.2.0.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			for file in gcc/config/{linux,i386/linux{,64}}.h; do
				cp -u $file{,.orig}
				sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $file.orig > $file
				cat >> ${file} <<- EOF

					#undef STANDARD_STARTFILE_PREFIX_1
					#undef STANDARD_STARTFILE_PREFIX_2
					#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
					#define STANDARD_STARTFILE_PREFIX_2 ""
				EOF
				touch $file.orig
			done
			case ${HOSTTYPE} in
				x86_64)	sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
					;;
			esac
			unpack mpfr-4.0.2.tar.xz
			unpack gmp-6.1.2.tar.xz
			unpack mpc-1.1.0.tar.gz
			mv -v mpfr-4.0.2 mpfr >> ${logfile} 2>&1
			mv -v gmp-6.1.2 gmp >> ${logfile} 2>&1
			mv -v mpc-1.1.0 mpc >> ${logfile} 2>&1
			mkdir build 
			pushd build >> /dev/null 2>&1
				msg_line "	Configure: "
					../configure \
						--target=${LFS_TGT} \
						--prefix=/tools \
						--with-glibc-version=2.11 \
						--with-sysroot=${LFS} \
						--with-newlib \
						--without-headers \
						--with-local-prefix=/tools \
						--with-native-system-header-dir=/tools/include \
						--disable-nls \
						--disable-shared \
						--disable-multilib \
						--disable-decimal-float \
						--disable-threads \
						--disable-libatomic \
						--disable-libgomp \
						--disable-libmpx \
						--disable-libquadmath \
						--disable-libssp \
						--disable-libvtv \
						--disable-libstdcxx \
						--enable-languages=c,c++ >> ${logfile} 2>&1
				msg_success	
				msg_line "	     Make: "
					make ${MKFLAGS} >> ${logfile} 2>&1
				msg_success
				msg_line "	  Install: "
					make install >> ${logfile} 2>&1
				msg_success
			popd > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Linux-API-Headers {
	#	Linux-4.20.7 API Headers
	local pkg=linux-4.20.12.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	     Make: "
				make mrproper  >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make INSTALL_HDR_PATH=dest headers_install  >> ${logfile} 2>&1
				cp -rv dest/include/* /tools/include  >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Glibc {
	#	Glibc-2.29
	local pkg=glibc-2.29.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			mkdir build 
			pushd build >> /dev/null 2>&1
				msg_line "	Configure: "
					../configure \
						--prefix=/tools \
						--host=${LFS_TGT} \
						--build=$(../scripts/config.guess) \
						--enable-kernel=3.2 \
						--with-headers=/tools/include >> ${logfile} 2>&1
				msg_success	
				msg_line "	     Make: "
					make ${MKFLAGS} >> ${logfile} 2>&1
				msg_success
				msg_line "	  Install: "
					make install >> ${logfile} 2>&1
				msg_success
			popd > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	msg_line " Testing glibc: "
		echo 'int main(){}' > dummy.c
		${LFS_TGT}-gcc dummy.c	>> ${logfile}.test 2>&1
		echo "Test: [Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2]" >> ${logfile}.test 2>&1
		readelf -l a.out | grep ': /tools' >> ${logfile}.test 2>&1
		rm dummy.c a.out
	msg_success
	return
}
function Libstdc {
	#	Libstdc++ from GCC-8.2.0
	local pkg=gcc-8.2.0.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
			pushd ${pkg_dir} >> /dev/null 2>&1
			mkdir build 
			pushd build >> /dev/null 2>&1
				msg_line "	Configure: "
					../libstdc++-v3/configure \
						--host=${LFS_TGT} \
						--prefix=/tools \
						--disable-multilib \
						--disable-nls \
						--disable-libstdcxx-threads \
						--disable-libstdcxx-pch \
						--with-gxx-include-dir=/tools/${LFS_TGT}/include/c++/8.2.0 >> ${logfile} 2>&1
				msg_success	
				msg_line "	     Make: "
					make ${MKFLAGS} >> ${logfile} 2>&1
				msg_success
				msg_line "	  Install: "
					make install >> ${logfile} 2>&1
				msg_success
			popd > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Binutils-Pass-2 {
	#	Binutils-2.32 - Pass 2
	local pkg=binutils-2.32.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			mkdir build 
			pushd build >> /dev/null 2>&1
				msg_line "	Configure: "
					CC=${LFS_TGT}-gcc \
					AR=${LFS_TGT}-ar \
					RANLIB=${LFS_TGT}-ranlib \
					../configure \
						--prefix=/tools \
						--disable-nls \
						--disable-werror \
						--with-lib-path=/tools/lib \
						--with-sysroot >> ${logfile} 2>&1
				msg_success
				msg_line "	     Make: "
					make ${MKFLAGS} >> ${logfile} 2>&1
				msg_success
				msg_line "	  Install: "
					make install >> ${logfile} 2>&1
				msg_success
				msg_line "	Prepare the linker for Re-adjusting: "
					make -C ld clean >> ${logfile} 2>&1
					make -C ld LIB_PATH=/usr/lib:/lib >> ${logfile} 2>&1
					cp -v ld/ld-new /tools/bin >> ${logfile} 2>&1
				msg_success
			popd > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function GCC-Pass-2 {
	#	GCC-8.2.0 - Pass 2
	local pkg=gcc-8.2.0.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			cat gcc/limitx.h gcc/glimits.h gcc/limity.h > `dirname $(${LFS_TGT}-gcc -print-libgcc-file-name)`/include-fixed/limits.h
			for file in gcc/config/{linux,i386/linux{,64}}.h; do
				cp -u $file{,.orig}  >> ${logfile} 2>&1
				sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' -e 's@/usr@/tools@g' $file.orig > $file
				cat >> ${file} <<- EOF

					#undef STANDARD_STARTFILE_PREFIX_1
					#undef STANDARD_STARTFILE_PREFIX_2
					#define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
					#define STANDARD_STARTFILE_PREFIX_2 ""
				EOF
				touch $file.orig
			done
			case ${HOSTTYPE} in
				x86_64) sed -e '/m64=/s/lib64/lib/' -i.orig gcc/config/i386/t-linux64
					;;
			esac
			unpack mpfr-4.0.2.tar.xz
			unpack gmp-6.1.2.tar.xz
			unpack mpc-1.1.0.tar.gz
			mv -v mpfr-4.0.2 mpfr >> ${logfile} 2>&1
			mv -v gmp-6.1.2 gmp >> ${logfile} 2>&1
			mv -v mpc-1.1.0 mpc >> ${logfile} 2>&1
			mkdir build
			pushd build >> /dev/null 2>&1
				msg_line "	Configure: "
					CC=${LFS_TGT}-gcc \
					CXX=${LFS_TGT}-g++ \
					AR=${LFS_TGT}-ar \
					RANLIB=${LFS_TGT}-ranlib \
					../configure \
						--prefix=/tools \
						--with-local-prefix=/tools \
						--with-native-system-header-dir=/tools/include \
						--enable-languages=c,c++ \
						--disable-libstdcxx-pch \
						--disable-multilib \
						--disable-bootstrap \
						--disable-libgomp >> ${logfile} 2>&1
				msg_success	
				msg_line "	     Make: "
					make ${MKFLAGS} >> ${logfile} 2>&1
				msg_success
				msg_line "	  Install: "
					make install >> ${logfile} 2>&1
					ln -sv gcc /tools/bin/cc >> ${logfile} 2>&1
				msg_success
			popd > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	msg_line "Testing gcc pass-2: "
		echo 'int main(){}' > dummy.c
		cc dummy.c >> ${logfile}.test 2>&1
		echo "Test: [Requesting program interpreter: /tools/lib64/ld-linux-x86-64.so.2]" >> ${logfile}.test 2>&1
		readelf -l a.out | grep ': /tools'	>> ${logfile}.test 2>&1
		rm dummy.c a.out
	msg_success
	return
}
function Tcl {
	#	Tcl-8.6.9
	local pkg=tcl8.6.9-src.tar.gz
	local pkg_dir=${pkg%%-src*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			cd unix
			msg_line "	Configure: "
				./configure  --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
				chmod -v u+w /tools/lib/libtcl8.6.so >> ${logfile} 2>&1
				make install-private-headers >> ${logfile} 2>&1
				ln -sv tclsh8.6 /tools/bin/tclsh >> ${logfile} 2>&1
			msg_success
			cd -
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Expect {
	#	Expect-5.45.4
	local pkg=expect5.45.4.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				cp -v configure{,.orig}  >> ${logfile} 2>&1
				sed 's:/usr/local/bin:/bin:' configure.orig > configure
				./configure \
					--prefix=/tools \
					--with-tcl=/tools/lib \
					--with-tclinclude=/tools/include>> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make SCRIPTS="" install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function DejaGNU {
	#	DejaGNU-1.6.2
	local pkg=dejagnu-1.6.2.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
#	M4-1.4.18
function M4 {
	#	M4-1.4.18
	local pkg=m4-1.4.18.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' lib/*.c  >> ${logfile} 2>&1
				echo "#define _IO_IN_BACKUP 0x100" >> lib/stdio-impl.h
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Ncurses {
	#	Ncurses-6.1
	local pkg=ncurses-6.1.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				sed -i s/mawk// configure >> ${logfile} 2>&1
				./configure \
					--prefix=/tools \
					--with-shared \
					--without-debug \
					--without-ada \
					--enable-widec \
					--enable-overwrite >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
				ln -s libncursesw.so /tools/lib/libncurses.so >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Bash {
	#	Bash-5.0
	local pkg=bash-5.0.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools --without-bash-malloc >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
				ln -sv bash /tools/bin/sh >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Bison {
	#	Bison-3.3.2
	local pkg=bison-3.3.2.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Bzip {
	#	Bzip2-1.0.6
	local pkg=bzip2-1.0.6.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	local OPTFLAGS=" -march=x86-64 -mtune=generic -O2 -pipe -fPIC "
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				sed -i "s|-O2|${OPTFLAGS}|g" Makefile
				sed -i "s|-O2|${OPTFLAGS}|g" Makefile-libbz2_so
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make PREFIX=/tools install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Coreutils {
	#	Coreutils-8.30
	local pkg=coreutils-8.30.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools --enable-install-program=hostname >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Diffutils {
	#	Diffutils-3.7
	local pkg=diffutils-3.7.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function File {
	#	File-5.35
	local pkg=file-5.36.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Findutils {
	#	Findutils-4.6.0
	local pkg=findutils-4.6.0.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			sed -i 's/IO_ftrylockfile/IO_EOF_SEEN/' gl/lib/*.c
			sed -i '/unistd/a #include <sys/sysmacros.h>' gl/lib/mountlist.c
			echo "#define _IO_IN_BACKUP 0x100" >> gl/lib/stdio-impl.h
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Gawk {
	#	Gawk-4.2.1
	local pkg=gawk-4.2.1.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Gettext {
	#	Gettext-0.19.8.1
	local pkg=gettext-0.19.8.1.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			cd gettext-tools > /dev/null 2>&1
			msg_line "	Configure: "
				EMACS="no" ./configure --prefix=/tools --disable-shared >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make  ${MKFLAGS} -C gnulib-lib >> ${logfile} 2>&1
				make  ${MKFLAGS} -C intl pluralx.c >> ${logfile} 2>&1
				make  ${MKFLAGS} -C src msgfmt >> ${logfile} 2>&1
				make  ${MKFLAGS} -C src msgmerge >> ${logfile} 2>&1
				make  ${MKFLAGS} -C src xgettext >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				cp -v src/{msgfmt,msgmerge,xgettext} /tools/bin >> ${logfile} 2>&1
			msg_success
			cd - > /dev/null 2>&1
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Grep {
	#	Grep-3.3
	local pkg=grep-3.3.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Gzip {
	#	Gzip-1.10
	local pkg=gzip-1.10.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Make {
	#	Make-4.2.1
	local pkg=make-4.2.1.tar.bz2
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				sed -i '211,217 d; 219,229 d; 232 d' glob/glob.c
				./configure --prefix=/tools --without-guile >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Patch {
	#	Patch-2.7.6
	local pkg=patch-2.7.6.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Perl {
	#	Perl-5.28.1
	local pkg=perl-5.28.1.tar.xz
#	local pkg=perl-5.26.1.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				sh Configure -des -Dprefix=/tools -Dlibs=-lm -Uloclibpth -Ulocincpth >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				# ulimit -s unlimited
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				cp -v perl cpan/podlators/scripts/pod2man /tools/bin >> ${logfile} 2>&1
				mkdir -pv /tools/lib/perl5/5.28.1 >> ${logfile} 2>&1
				cp -Rv lib/* /tools/lib/perl5/5.28.1 >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Python {
	#	Python-3.7.2
	local pkg=Python-3.7.2.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				sed -i '/def add_multiarch_paths/a \        return' setup.py
				./configure --prefix=/tools --without-ensurepip >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Sed {
	#	Sed-4.7
	local pkg=sed-4.7.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Tar {
	#	Tar-1.31
	local pkg=tar-1.31.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Texinfo {
	#	Texinfo-6.5
	local pkg=texinfo-6.5.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Xz {
	#	Xz-5.2.4
	local pkg=xz-5.2.4.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure --prefix=/tools >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make install >> ${logfile} 2>&1
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
#	RPM STUFF
function Zlib {
	local pkg=zlib-1.2.11.tar.xz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	local OPTFLAGS="-march=x86-64 -mtune=generic -O2 -pipe -fPIC"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	install -dm 755 ${TOPDIR}/BUILDROOT
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				CFLAGS=${OPTFLAGS} \
				CXXFLAGS=${OPTFLAGS} \
				./configure \
					--prefix=/tools \
					--static  >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make DESTDIR=${TOPDIR}/BUILDROOT install >> ${logfile} 2>&1
				rm -rf  ${TOPDIR}/BUILDROOT/tools/share
				cp -ar ${TOPDIR}/BUILDROOT/tools/* /tools
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Popt {
	local pkg=popt-1.16.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure \
					--prefix=/tools \
					--disable-shared \
					--enable-static >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make DESTDIR=${TOPDIR}/BUILDROOT install >> ${logfile} 2>&1
				rm -rf ${TOPDIR}/BUILDROOT/tools/lib/libpopt.la
				rm -rf ${TOPDIR}/BUILDROOT/tools/share
				cp -ar ${TOPDIR}/BUILDROOT/tools/* /tools
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Openssl {
	local pkg=openssl-1.1.1a.tar.gz
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./config \
					--prefix=/tools \
					--openssldir=/tools/etc/ssl \
					no-shared \
					no-zlib \
					enable-md2  >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make DESTDIR=${TOPDIR}/BUILDROOT install >> ${logfile} 2>&1
				rm -rf ${TOPDIR}/BUILDROOT/tools/share
				cp -a  ${TOPDIR}/BUILDROOT/tools/bin/* /tools/bin/
				cp -ar ${TOPDIR}/BUILDROOT/tools/etc/* /tools/etc/
				cp -ar ${TOPDIR}/BUILDROOT/tools/include/* /tools/include/
				cp -ar ${TOPDIR}/BUILDROOT/tools/lib64/* /tools/lib/
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Libelf {
	local pkg=elfutils-0.176.tar.bz2
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	install -dm 755 ${TOPDIR}/BUILDROOT
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			msg_line "	Configure: "
				./configure \
					--prefix=/tools \
					--program-prefix="eu-" \
					--disable-shared \
					--enable-static  >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make DESTDIR=${TOPDIR}/BUILDROOT -C libelf install >> ${logfile} 2>&1
				install -Dm644 config/libelf.pc ${TOPDIR}/BUILDROOT/tools/lib/pkgconfig/libelf.pc
				cp -ar ${TOPDIR}/BUILDROOT/tools/* /tools
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Rpm {
	local pkg=rpm-4.14.2.1.tar.bz2
	local pkg_dir=${pkg%%.tar*}
	local logfile="${TOPDIR}/LOGS/tools-${FUNCNAME}.log"
	[ -e ${logfile}.complete ] && { msg "Skipping: ${FUNCNAME}";return 0; } || msg "Building: ${FUNCNAME}"
	> ${logfile}
	pushd ${TOPDIR}/BUILD >> /dev/null 2>&1
		unpack "${pkg}"
		pushd ${pkg_dir} >> /dev/null 2>&1
			unpack db-6.0.20.tar.gz
			msg_line "	Configure: "
			sed -i 's/--srcdir=$db_dist/--srcdir=$db_dist --with-pic/' db3/configure
			ln -vs db-6.0.20 db >> ${logfile} 2>&1
			./configure \
				--prefix=/tools \
				--program-prefix= \
				--sysconfdir=/tools/etc \
				--with-crypto=openssl \
				--without-external-db \
				--without-archive \
				--without-lua \
				--disable-dependency-tracking \
				--disable-silent-rules \
				--disable-rpath \
				--disable-plugins \
				--disable-inhibit-plugin \
				--disable-shared \
				--enable-static \
				--enable-zstd=no \
				--enable-lmdb=no >> ${logfile} 2>&1
			msg_success	
			msg_line "	     Make: "
				make ${MKFLAGS} >> ${logfile} 2>&1
			msg_success
			msg_line "	  Install: "
				make DESTDIR=${TOPDIR}/BUILDROOT install >> ${logfile} 2>&1
				rm -rf ${TOPDIR}/BUILDROOT/tools/share
				rm -rf ${TOPDIR}/BUILDROOT/tools/lib/*.la
				rm -rf ${TOPDIR}/BUILDROOT/tools/lib/rpm-plugins/*.la
				cp -ar ${TOPDIR}/BUILDROOT/tools/* /tools
			msg_success
		popd > /dev/null 2>&1
	popd > /dev/null 2>&1
	#	This is for rpm and rpmbuild 
	[ -d ${LFS}/tmp ]		|| install -vdm 755 ${LFS}/tmp
	[ -d ${LFS}/bin ]		|| install -vdm 755 ${LFS}/bin
	[ -d ${LFS}/usr/bin ]		|| install -vdm 755 ${LFS}/usr/bin
	[ -h ${LFS}/bin/sh ]		|| ln -sf /tools/bin/bash ${LFS}/bin/sh
	[ -h ${LFS}/bin/bash ]		|| ln -sf /tools/bin/bash ${LFS}/bin
	[ -h ${LFS}//usr/bin/getconf ]	|| ln -sf /tools/bin/getconf ${LFS}/usr/bin
	[ -d ${LFS}/tools/etc/rpm ]	|| install -vdm 755 ${LFS}/tools/etc/rpm
	cp SOURCES/macros ${LFS}/tools/etc/rpm/macros
	clean-build-directory
	mv ${logfile} ${logfile}.complete
	return
}
function Remove_files {
	msg_line "Removing unnecessary files: "
	#	/tools/bin
	rm -f  /mnt/lfs/tools/bin/c_rehash
	rm -f  /mnt/lfs/tools/bin/gendiff
	rm -f  /mnt/lfs/tools/bin/openssl
	#	/tools/lib/pkgconfig
	rm -f  /mnt/lfs/tools/lib/pkgconfig/libcrypto.pc
	rm -f  /mnt/lfs/tools/lib/pkgconfig/libelf.pc
	rm -f  /mnt/lfs/tools/lib/pkgconfig/libssl.pc
	rm -f  /mnt/lfs/tools/lib/pkgconfig/openssl.pc
	rm -f  /mnt/lfs/tools/lib/pkgconfig/popt.pc
	rm -f  /mnt/lfs/tools/lib/pkgconfig/rpm.pc
	rm -f  /mnt/lfs/tools/lib/pkgconfig/zlib.pc
	#	/tools/etc/ssl
	rm -fr /mnt/lfs/tools/etc/ssl
	#	/tools/include
	rm -fr /mnt/lfs/tools/include/elfutils
	rm -f  /mnt/lfs/tools/include/gelf.h
	rm -f  /mnt/lfs/tools/include/libelf.h
	rm -f  /mnt/lfs/tools/include/nlist.h
	rm -fr /mnt/lfs/tools/include/openssl
	rm -f  /mnt/lfs/tools/include/popt.h
	rm -fr /mnt/lfs/tools/include/rpm
	rm -f  /mnt/lfs/tools/include/zconf.h
	rm -f  /mnt/lfs/tools/include/zlib.h
	#	/tools/lib
	rm -fr /mnt/lfs/tools/lib/engines-1.1
	rm -f  /mnt/lfs/tools/lib/libcrypto.a
	rm -f  /mnt/lfs/tools/lib/libssl.a
	rm -rf /mnt/lfs/tools/lib/libz.a
	rm -f  /mnt/lfs/tools/lib/libelf.a
	rm -f  /mnt/lfs/tools/lib/libpopt.a
	rm -f  /mnt/lfs/tools/lib/librpm.a
	rm -f  /mnt/lfs/tools/lib/librpmbuild.a
	rm -f  /mnt/lfs/tools/lib/librpmio.a
	rm -f  /mnt/lfs/tools/lib/librpmsign.a
	find /tools/{lib,libexec} -name \*.la -delete
	msg_success
	return 
}
#-----------------------------------------------------------------------------
#	Mainline
LIST=""
LIST+="_sanity set-mkflags clean-build-directory "
LIST+="Binutils-Pass-1 "
LIST+="GCC-Pass-1 "
LIST+="Linux-API-Headers "
LIST+="Glibc "
LIST+="Libstdc "
LIST+="Binutils-Pass-2 "
LIST+="GCC-Pass-2 "
LIST+="Tcl "
LIST+="Expect "
LIST+="DejaGNU "
LIST+="M4 "
LIST+="Ncurses "
LIST+="Bash "
LIST+="Bison "
LIST+="Bzip "
LIST+="Coreutils "
LIST+="Diffutils "
LIST+="File "
LIST+="Findutils "
LIST+="Gawk "
LIST+="Gettext "
LIST+="Grep "
LIST+="Gzip "
LIST+="Make "
LIST+="Patch "
LIST+="Perl "
LIST+="Python "
LIST+="Sed "
LIST+="Tar "
LIST+="Texinfo "
LIST+="Xz "
#	rpm stuff
LIST+="Zlib "
LIST+="Popt "
LIST+="Openssl "
LIST+="Libelf "
LIST+="Rpm "
LIST+="Remove_files "
for i in ${LIST};do ${i};done
end_run
