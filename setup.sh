#!/bin/bash
#-----------------------------------------------------------------------------
#	  Title: setup.sh
#	   Date: 2019-02-15
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
set +h		# disable hashall
#-----------------------------------------------------------------------------
#	Common variables
PRGNAME=${0##*/}	# Script name minus the path
TOPDIR=${PWD}		# This directory
LFS=/mnt/lfs		# Where LFS will be installed to
PARENT=/usr/src/LFS-RPM	# Where build system wil live
SWAP_FILE_SIZE=1024	# Size of swap file in MB
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
	local size=""
	msg_line "	Checking to see if running as root: "
		[ "$EUID" -ne 0 ] && die "You need be running as root for this script"
        msg_success
	msg_line "	Checking if LFS variable is set: "
		[ -v LFS ] || die "LFS environment variable missing/not set"
	msg_success
	msg_line "	Checking if ${LFS} is mounted: "
		mountpoint -q ${LFS} || die "${LFS} is not mounted"
	msg_success
	#	check for swap space and add some in there is no swap
	size=$(free | grep 'Swap:' | tr -d ' ' | cut -d ':' -f2)
	case ${size} in
		"000")
			msg "	Creating swap file: ${LFS}/swapfile: "
				dd if=/dev/zero of=${LFS}/swapfile status=progress bs=1M count=${SWAP_FILE_SIZE}
				chmod 600 ${LFS}/swapfile
				mkswap ${LFS}/swapfile
				swapon -v ${LFS}/swapfile
			msg_success	;;
		*)	;;
	esac
	return
}
function _chapter_3 {
#	3. Packages and Patches
#		Introduction
#		All Packages
#		Needed Patches
	local i=""
	local list=""
	if [ ${PWD} != ${LFS}${PARENT} ]; then
		msg_line "	Install build system: "
			[ -d ${LFS}/${PARENT} ] || install -dm 755 ${LFS}${PARENT}
			cp -ar ${TOPDIR}/BOOK		${LFS}${PARENT}
			cp -ar ${TOPDIR}/SOURCES	${LFS}${PARENT}
			cp -ar ${TOPDIR}/SPECS		${LFS}${PARENT}
			cp -a  ${TOPDIR}/README		${LFS}${PARENT}
			cp -a  ${TOPDIR}/*.sh		${LFS}${PARENT}			
			chmod +x ${LFS}${PARENT}/*.sh
		msg_success
	fi
	#	Create download list
	while IFS= read -r i; do
		list+="${i} "
	done < "${TOPDIR}/BOOK/wget-list"
	list+="https://src.fedoraproject.org/repo/pkgs/popt/popt-1.16.tar.gz/3743beefa3dd6247a73f8f7a32c14c33/popt-1.16.tar.gz "
	list+="http://ftp.rpm.org/releases/rpm-4.14.x/rpm-4.14.2.1.tar.bz2 "
	list+="https://ftp.osuosl.org/pub/blfs/conglomeration/db/db-6.0.20.tar.gz "
	list+="https://ftp.gnu.org/gnu/cpio/cpio-2.12.tar.bz2 "
	list+="https://ftp.gnu.org/gnu/wget/wget-1.20.1.tar.gz "
	for i in ${list}; do
		msg_line "	Fetching: ${i}: "
			wget --quiet --no-clobber --no-check-certificate --continue --directory-prefix=${LFS}${PARENT}/SOURCES ${i} || die "${PRGNAME}: Error: ${i}: Fetching tarball"
		msg_success
	done
	#	Create md5sum list
	while read i;do
		pushd ${LFS}${PARENT}/SOURCES > /dev/null 2>&1
		printf "%s\n" "${i}" > md5sums
		msg_line "	Verifying: ${i#*'  '}: "
		md5sum --status -c md5sums && msg_success || msg_failure
		popd > /dev/null 2>&1
	done < "${TOPDIR}/BOOK/md5sums"
	return
}
function _chapter_4 {
#	4. Final Preparations
#	Introduction
#	Creating the $LFS/tools Directory
#	Adding the LFS User
#	Setting Up the Environment
#	About SBUs
#	About the Test Suites
	local target=""
	#	Creating the $LFS/tools Directory
	msg_line "	Checking for ${LFS}/tools directory: "
		[ -d ${LFS}/tools ] || install -dm 755 ${LFS}/tools
	msg_success
	msg_line "	Checking for /tools symlink: "
		[ -h /tools ] || ln -s ${LFS}/tools /
	msg_success
	msg_line "	Creating lfs user: "
		getent group  lfs > /dev/null 2>&1 || groupadd lfs > /dev/null 2>&1
		getent passwd lfs > /dev/null 2>&1 || useradd  -c 'LFS user' -g lfs -m -k /dev/null -s /bin/bash lfs > /dev/null 2>&1
		getent passwd lfs > /dev/null 2>&1 && passwd --delete lfs > /dev/null 2>&1
	msg_success
	msg_line "	Setting Up the Environment: "
		[ -d /home/lfs ] || install -dm 755 /home/lfs
		cat > /home/lfs/.bash_profile <<- EOF
			exec env -i HOME=/home/lfs TERM=${TERM} PS1='\u:\w\$ ' /bin/bash
		EOF
		cat > /home/lfs/.bashrc <<- EOF
			set +h
			umask 022
			LFS=/mnt/lfs
			LC_ALL=POSIX
			LFS_TGT=$(uname -m)-lfs-${OSTYPE}
			PATH=/tools/bin:/bin:/usr/bin
			export LFS LC_ALL LFS_TGT PATH
		EOF
		chown -R lfs:lfs /home/lfs	|| die "${PRGNAME}: ${FUNCNAME}: FAILURE"
		chown -R lfs:lfs ${LFS}		|| die "${PRGNAME}: ${FUNCNAME}: FAILURE"
	msg_success
	return
}
#-----------------------------------------------------------------------------
#	Main line
LIST=""
LIST+="_sanity "	# Sanity checks
LIST+="_chapter_3 "	# Chapter 3 Packages and Patches
LIST+="_chapter_4 "	# Chapter 4 Final Preparations
for i in ${LIST};do ${i};done
end_run
