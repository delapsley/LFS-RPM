#!/bin/bash
#-----------------------------------------------------------------------------
#	Title: lfs.sh
#	Date: 2019-05-22
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
USER=lfs			# build user
LFS=/mnt/lfs			# build area
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
#	sanity check
[ -v LFS ] || die "LFS environment variable missing/not set"
[ -d ${LFS}/${PARENT} ] || die "${LFS}${PARENT} directory missing"
cd ${LFS}${PARENT}
su --login ${USER} <<- "EOF"
	source ~/.bashrc
	cd /mnt/lfs/usr/src/LFS-RPM
	./tools.sh
EOF
msg_line "	Unmounting Virtual Kernel File Systems: "
	mountpoint -q ${LFS}/run && umount ${LFS}/run
	mountpoint -q ${LFS}/sys && umount ${LFS}/sys
	mountpoint -q ${LFS}/proc && umount ${LFS}/proc
	mountpoint -q ${LFS}/dev/pts && umount ${LFS}/dev/pts
	mountpoint -q ${LFS}/dev && umount ${LFS}/dev
msg_success
msg_line "	Changing file ownership: "
	chown -R 0:0 ${LFS}
msg_success
msg_line "	Preparing Virtual Kernel File Systems: "
	[ -d ${LFS}/dev ] || mkdir -p ${LFS}/dev
	[ -d ${LFS}/proc ] || mkdir -p ${LFS}/proc
	[ -d ${LFS}/sys ] || mkdir -p ${LFS}/sys
	[ -d ${LFS}/run ] || mkdir -p ${LFS}/run
	[ -e ${LFS}/dev/console ] || mknod -m 600 ${LFS}/dev/console c 5 1
	[ -e ${LFS}/dev/null ] || mknod -m 666 ${LFS}/dev/null c 1 3
msg_success
msg_line "	Mounting Virtual Kernel File Systems: "
	mountpoint -q ${LFS}/dev || mount --bind /dev ${LFS}/dev
	mountpoint -q ${LFS}/dev/pts || mount -t devpts devpts ${LFS}/dev/pts -o gid=5,mode=620
	mountpoint -q ${LFS}/proc || mount -t proc proc ${LFS}/proc
	mountpoint -q ${LFS}/sys || mount -t sysfs sysfs ${LFS}/sys
	mountpoint -q ${LFS}/run || mount -t tmpfs tmpfs ${LFS}/run
	[ -h ${LFS}/dev/shm ] && mkdir -p ${LFS}/$(readlink ${LFS}/dev/shm)
msg_success
chroot "$LFS" /tools/bin/env -i \
	HOME=/root \
	TERM="$TERM" \
	PS1='(lfs chroot) \u:\w\$ ' \
	PATH=/bin:/usr/bin:/sbin:/usr/sbin:/tools/bin \
	/tools/bin/bash --login +h -c "cd ${PARENT};./base.sh"
msg_line "	Unmounting Virtual Kernel File Systems: "
	mountpoint -q ${LFS}/run && umount ${LFS}/run
	mountpoint -q ${LFS}/sys && umount ${LFS}/sys
	mountpoint -q ${LFS}/proc && umount ${LFS}/proc
	mountpoint -q ${LFS}/dev/pts && umount ${LFS}/dev/pts
	mountpoint -q ${LFS}/dev && umount ${LFS}/dev
msg_success
end_run
