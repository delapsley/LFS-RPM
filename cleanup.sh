#!/bin/bash
#-----------------------------------------------------------------------------
#	  Title: cleanup.sh
#	   Date: 2019-05-22
#	Version: 1.0
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
#	This script removes changes made to the host system and
#	also removes the build tool chain chapter 5 packages as they are no 
#	longer needed. It will also unmount the /mnt/lfs filesystem
#-----------------------------------------------------------------------------
set -o errexit	# exit if error...insurance ;)
set -o nounset	# exit if variable not initalized
set +h			# disable hashall
#-----------------------------------------------------------------------------
PRGNAME=${0##*/}		#	script name minus the path
LFS=/mnt/lfs			#	build area
TOOLCHAIN="${LFS}/tools"	#	tool chain directory
LINK=/tools			#	tool chain symlink
USER=lfs			#	build user
#-----------------------------------------------------------------------------
function die() {
	local _red="\\033[1;31m"
	local _normal="\\033[0;39m"
	[ -n "$*" ] && printf "${_red}$*${_normal}\n"
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
msg_line "Checking to see if running as root: "
	[ "$EUID" -ne 0 ] && die "You need be running as root for this script"
msg_success
msg_line "Remove chapter 5 tool chain: "
	[ -d "${TOOLCHAIN}" ] && rm -rf "${TOOLCHAIN}"
	[ -h "${LINK}" ] && rm ${LINK}
msg_success
msg_line "Removing lfs user: "
	getent passwd ${USER} > /dev/null 2>&1 && userdel -r ${USER} > /dev/null 2>&1
msg_success
end_run
