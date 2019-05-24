#TARBALL:
#MD5SUM:
#-----------------------------------------------------------------------------
Summary:	Default file system
Name:		filesystem
Version:	8.4
Release:	1
License:	None
Group:		LFS/Base
Vendor:	Elizabeth
URL:		http://www.linuxfromscratch.org
%description
The filesystem package is one of the basic packages that is installed
on a Linux system. Filesystem contains the basic directory
layout for a Linux operating system, including the correct permissions
for the directories.
#-----------------------------------------------------------------------------
%prep
%build
%install
#-----------------------------------------------------------------------------
#	6.5.  Creating Directories
#-----------------------------------------------------------------------------
#	root directories
install -vdm 755 %{buildroot}/{bin,boot,dev,etc,home,lib,lib64,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
#	etc directories
install -vdm 755 %{buildroot}/etc/{ld.so.conf.d,opt,profile.d,skel,sysconfig}
#	init script directories - this is for chkconfig
install -vdm 755 %{buildroot}/etc/rc.d/{init.d,rc0.d,rc1.d,rc2.d,rc3.d,rc4.d,rc5.d,rc6.d,rc7.d}
ln -vs rc7.d %{buildroot}/etc/rc.d/rcS.d
#	lib directories
install -vdm 755 %{buildroot}/lib/firmware
#	media directories
install -vdm 755 %{buildroot}/media/{floppy,cdrom}
#	usr directories
install -vdm 755 %{buildroot}/usr/{,local/}{bin,include,lib,sbin,src}
install -vdm 755 %{buildroot}/usr/{,local/}share/{color,dict,doc,info,locale,man}
install -vdm 755 %{buildroot}/usr/{,local/}share/{misc,terminfo,zoneinfo}
install -vdm 755 %{buildroot}/usr/libexec
install -vdm 755 %{buildroot}/usr/{,local/}share/man/man{1..8}
#	var directories
install -vdm 755 %{buildroot}/var/{log,mail,spool,tmp}
install -vdm 755 %{buildroot}/var/{opt,cache,lib/{color,misc,locate,hwclock},local}
#	symlinks
ln -sv /run %{buildroot}/var/run
ln -sv /run/lock %{buildroot}/var/lock
ln -sv /proc/self/mounts %{buildroot}/etc/mtab
touch %{buildroot}/var/log/{btmp,lastlog,faillog,wtmp}
chgrp -v 13	%{buildroot}/var/log/lastlog
chmod -v 664	%{buildroot}/var/log/lastlog
chmod -v 600	%{buildroot}/var/log/btmp
#-----------------------------------------------------------------------------
#	6.2. Preparing Virtual Kernel File Systems
#-----------------------------------------------------------------------------
mknod -m 600 %{buildroot}/dev/console c 5 1
mknod -m 666 %{buildroot}/dev/null c 1 3
#-----------------------------------------------------------------------------
#	6.6. Creating Essential Files and Symlinks
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/passwd <<- EOF
	root:x:0:0:root:/root:/bin/bash
	bin:x:1:1:bin:/dev/null:/bin/false
	daemon:x:6:6:Daemon User:/dev/null:/bin/false
	messagebus:x:18:18:D-Bus Message Daemon User:/var/run/dbus:/bin/false
	nobody:x:99:99:Unprivileged User:/dev/null:/bin/false
EOF
cat > %{buildroot}/etc/group <<- EOF
	root:x:0:
	bin:x:1:daemon
	sys:x:2:
	kmem:x:3:
	tape:x:4:
	tty:x:5:
	daemon:x:6:
	floppy:x:7:
	disk:x:8:
	lp:x:9:
	dialout:x:10:
	audio:x:11:
	video:x:12:
	utmp:x:13:
	usb:x:14:
	cdrom:x:15:
	adm:x:16:
	messagebus:x:18:
	input:x:24:
	mail:x:34:
	kvm:x:61:
	wheel:x:97:
	nogroup:x:99:
	users:x:999:
EOF
#-----------------------------------------------------------------------------
#	7.5.1. Creating Network Interface Configuration Files
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/sysconfig/ifconfig.eth0 <<- "EOF"
	ONBOOT=yes
	IFACE=enp7s0
	SERVICE=ipv4-static
	IP=192.168.1.2
	GATEWAY=192.168.1.1
	PREFIX=24
	BROADCAST=192.168.1.255
EOF
#-----------------------------------------------------------------------------
#	7.5.2. Creating the /etc/resolv.conf File
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/resolv.conf <<- "EOF"
# Begin /etc/resolv.conf

	domain     example.org
	nameserver <IP address of your primary nameserver>
	nameserver <IP address of your secondary nameserver>

# End /etc/resolv.conf
EOF
#-----------------------------------------------------------------------------
#	7.5.3. Configuring the system hostname
#-----------------------------------------------------------------------------
echo "lfs.example.org" > %{buildroot}/etc/hostname
#-----------------------------------------------------------------------------
#	7.5.4. Customizing the /etc/hosts File
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/hosts <<- "EOF"
# Begin /etc/hosts

	127.0.0.1	localhost
	192.168.1.2	lfs.example.org lfs
	::1		localhost ip6-localhost ip6-loopback
	ff02::1		ip6-allnodes
	ff02::2		ip6-allrouters

# End /etc/hosts
EOF
#-----------------------------------------------------------------------------
#	7.6.2. Configuring Sysvinit
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/inittab <<- "EOF"
# Begin /etc/inittab

	id:3:initdefault:

	si::sysinit:/etc/rc.d/init.d/rc S

	l0:0:wait:/etc/rc.d/init.d/rc 0
	l1:S1:wait:/etc/rc.d/init.d/rc 1
	l2:2:wait:/etc/rc.d/init.d/rc 2
	l3:3:wait:/etc/rc.d/init.d/rc 3
	l4:4:wait:/etc/rc.d/init.d/rc 4
	l5:5:wait:/etc/rc.d/init.d/rc 5
	l6:6:wait:/etc/rc.d/init.d/rc 6

	ca:12345:ctrlaltdel:/sbin/shutdown -t1 -a -r now

	su:S016:once:/sbin/sulogin

	1:2345:respawn:/sbin/agetty --noclear tty1 9600
	2:2345:respawn:/sbin/agetty tty2 9600
	3:2345:respawn:/sbin/agetty tty3 9600
	4:2345:respawn:/sbin/agetty tty4 9600
	5:2345:respawn:/sbin/agetty tty5 9600
	6:2345:respawn:/sbin/agetty tty6 9600

# End /etc/inittab
EOF
#-----------------------------------------------------------------------------
#	7.6.4. Configuring the System Clock
#-----------------------------------------------------------------------------
cat >  %{buildroot}/etc/sysconfig/clock <<- "EOF"
# Begin /etc/sysconfig/clock

# Change the value of the UTC variable below to a value of
# 0 (zero) if the hardware clock is not set to UTC time.

	UTC=1

# Set this to any options you might need to give to hwclock,
# such as machine hardware clock type for Alphas.
	CLOCKPARAMS=

# End /etc/sysconfig/clock
EOF
#-----------------------------------------------------------------------------
#	7.8. Creating the /etc/inputrc File
#-----------------------------------------------------------------------------
cat >  %{buildroot}/etc/inputrc <<- "EOF"
# Begin /etc/inputrc
# Modified by Chris Lynn <roryo@roryo.dynup.net>

# Allow the command prompt to wrap to the next line
	set horizontal-scroll-mode Off

# Enable 8bit input
	set meta-flag On
	set input-meta On

# Turns off 8th bit stripping
	set convert-meta Off

# Keep the 8th bit for display
	set output-meta On

# none, visible or audible
	set bell-style none

# All of the following map the escape sequence of the value
# contained in the 1st argument to the readline specific functions
	"\eOd": backward-word
	"\eOc": forward-word

# for linux console
	"\e[1~": beginning-of-line
	"\e[4~": end-of-line
	"\e[5~": beginning-of-history
	"\e[6~": end-of-history
	"\e[3~": delete-char
	"\e[2~": quoted-insert

# for xterm
	"\eOH": beginning-of-line
	"\eOF": end-of-line

# for Konsole
	"\e[H": beginning-of-line
	"\e[F": end-of-line

# End /etc/inputrc
EOF
#-----------------------------------------------------------------------------
#	7.9. Creating the /etc/shells File
#-----------------------------------------------------------------------------
cat >  %{buildroot}/etc/shells <<- "EOF"
# Begin /etc/shells

	/bin/sh
	/bin/bash

# End /etc/shells
EOF
#-----------------------------------------------------------------------------
#	8.2. Creating the /etc/fstab File
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/fstab <<- "EOF"
# Begin /etc/fstab

#	hdparm -I /dev/sda | grep NCQ --> can use barrier
# file system  mount-point  type     options                                     dump  fsck
#                                                                                      order
#/dev/sdxx     /            ext4     defaults,barrier,noatime,noacl,data=ordered 1     1
#/dev/sdxx     /            ext4     defaults                                    1     1
#/dev/sdxx     /boot        ext4     defaults                                    1     2
	/dev/<xxx>     /            ext4     defaults                                    1     1
	/dev/<yyy>     swap         swap     pri=1                                       0     0
	proc           /proc        proc     nosuid,noexec,nodev                         0     0
	sysfs          /sys         sysfs    nosuid,noexec,nodev                         0     0
	devpts         /dev/pts     devpts   gid=5,mode=620                              0     0
	tmpfs          /run         tmpfs    defaults                                    0     0
	devtmpfs       /dev         devtmpfs mode=0755,nosuid                            0     0
#tmpfs         /tmp         tmpfs    defaults                                    0     0

# End /etc/fstab
EOF
#-----------------------------------------------------------------------------
#	8.3.2. Configuring Linux Module Load Order
#-----------------------------------------------------------------------------
install -v -m755 -d %{buildroot}/etc/modprobe.d
cat > %{buildroot}/etc/modprobe.d/usb.conf <<- "EOF"
# Begin /etc/modprobe.d/usb.conf

	install ohci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i ohci_hcd ; true
	install uhci_hcd /sbin/modprobe ehci_hcd ; /sbin/modprobe -i uhci_hcd ; true

# End /etc/modprobe.d/usb.conf
EOF
#-----------------------------------------------------------------------------
#	9.1. The End
#-----------------------------------------------------------------------------
echo %{version} > %{buildroot}/etc/lfs-release
cat > %{buildroot}/etc/lsb-release <<- "EOF"
	DISTRIB_ID="Linux From Scratch"
	DISTRIB_RELEASE=%{version}
	DISTRIB_CODENAME="Elizabeth"
	DISTRIB_DESCRIPTION="Linux From Scratch"
EOF
#-----------------------------------------------------------------------------
#	BLFS scripts	-	About System Users and Groups
#-----------------------------------------------------------------------------
cat > %{buildroot}/etc/profile <<- "EOF"
# Begin /etc/profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# modifications by Dagmar d'Surreal <rivyqntzne@pbzpnfg.arg>

# System wide environment variables and startup programs.

# System wide aliases and functions should go in /etc/bashrc.  Personal
# environment variables and startup programs should go into
# ~/.bash_profile.  Personal aliases and functions should go into
# ~/.bashrc.

# Functions to help us manage paths.  Second argument is the name of the
# path variable to be modified (default: PATH)
	pathremove () {
	       local IFS=':'
	       local NEWPATH
	       local DIR
	       local PATHVARIABLE=${2:-PATH}
	       for DIR in ${!PATHVARIABLE} ; do
	              if [ "$DIR" != "$1" ] ; then
	                     NEWPATH=${NEWPATH:+$NEWPATH:}$DIR
	              fi
		done
	       export $PATHVARIABLE="$NEWPATH"
	}
	pathprepend () {
		pathremove $1 $2
		local PATHVARIABLE=${2:-PATH}
	       export $PATHVARIABLE="$1${!PATHVARIABLE:+:${!PATHVARIABLE}}"
	}
	pathappend () {
	       pathremove $1 $2
	       local PATHVARIABLE=${2:-PATH}
	       export $PATHVARIABLE="${!PATHVARIABLE:+${!PATHVARIABLE}:}$1"
	}
	export -f pathremove pathprepend pathappend
# Set the initial path
	export PATH=/bin:/usr/bin
	if [ $EUID -eq 0 ] ; then
	       pathappend /sbin:/usr/sbin
	       unset HISTFILE
	fi
# Setup some environment variables.
	export HISTSIZE=1000
	export HISTIGNORE="&:[bf]g:exit"
# Set some defaults for graphical systems
	export XDG_DATA_DIRS=${XDG_DATA_DIRS:-/usr/share/}
	export XDG_CONFIG_DIRS=${XDG_CONFIG_DIRS:-/etc/xdg/}
	export XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/tmp/xdg-$USER}
# Setup a red prompt for root and a green one for users.
	NORMAL="\[\e[0m\]"
	RED="\[\e[1;31m\]"
	GREEN="\[\e[1;32m\]"
	if [[ $EUID == 0 ]] ; then
	       PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
	else
	       PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
	fi
	for script in /etc/profile.d/*.sh ; do
	       if [ -r $script ] ; then
	              . $script
	       fi
	done
	unset script RED GREEN NORMAL
# End /etc/profile
EOF
cat > %{buildroot}/etc/profile.d/bash_completion.sh <<- "EOF"
# Begin /etc/profile.d/bash_completion.sh
# Import bash completion scripts
	for script in /etc/bash_completion.d/*.sh ; do
	       if [ -r $script ] ; then
	              . $script
	       fi
	done
# End /etc/profile.d/bash_completion.sh
EOF
cat > %{buildroot}/etc/profile.d/dircolors.sh <<- "EOF"
# Setup for /bin/ls and /bin/grep to support color, the alias is in /etc/bashrc.
	if [ -f "/etc/dircolors" ] ; then
	       eval $(dircolors -b /etc/dircolors)
	fi
	if [ -f "$HOME/.dircolors" ] ; then
	       eval $(dircolors -b $HOME/.dircolors)
	fi
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
EOF
cat > %{buildroot}/etc/profile.d/extrapaths.sh <<- "EOF"
	if [ -d /usr/local/lib/pkgconfig ] ; then
	       pathappend /usr/local/lib/pkgconfig PKG_CONFIG_PATH
	fi
	if [ -d /usr/local/bin ]; then
	       pathprepend /usr/local/bin
	fi
	if [ -d /usr/local/sbin -a $EUID -eq 0 ]; then
	       pathprepend /usr/local/sbin
	fi
# Set some defaults before other applications add to these paths.
	pathappend /usr/share/man  MANPATH
	pathappend /usr/share/info INFOPATH
EOF
cat > %{buildroot}/etc/profile.d/readline.sh <<- "EOF"
# Setup the INPUTRC environment variable.
	if [ -z "$INPUTRC" -a ! -f "$HOME/.inputrc" ] ; then
	       INPUTRC=/etc/inputrc
	fi
	export INPUTRC
EOF
cat > %{buildroot}/etc/profile.d/umask.sh <<- "EOF"
# By default, the umask should be set.
	if [ "$(id -gn)" = "$(id -un)" -a $EUID -gt 99 ] ; then
	       umask 002
	else
	       umask 022
	fi
EOF
cat > %{buildroot}/etc/profile.d/i18n.sh <<- "EOF"
# Set up i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>
EOF
cat > %{buildroot}/etc/bashrc <<- "EOF"
# Begin /etc/bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# System wide aliases and functions.

# System wide environment variables and startup programs should go into
# /etc/profile.  Personal environment variables and startup programs
# should go into ~/.bash_profile.  Personal aliases and functions should
# go into ~/.bashrc

# Provides colored /bin/ls and /bin/grep commands.  Used in conjunction
# with code in /etc/profile.
	alias ls='ls --color=auto'
	alias grep='grep --color=auto'
# Provides prompt for non-login shells, specifically shells started
# in the X environment. [Review the LFS archive thread titled
# PS1 Environment Variable for a great case study behind this script
# addendum.]
	NORMAL="\[\e[0m\]"
	RED="\[\e[1;31m\]"
	GREEN="\[\e[1;32m\]"
	if [[ $EUID == 0 ]] ; then
	       PS1="$RED\u [ $NORMAL\w$RED ]# $NORMAL"
	else
	       PS1="$GREEN\u [ $NORMAL\w$GREEN ]\$ $NORMAL"
	fi
	unset RED GREEN NORMAL
# End /etc/bashrc
EOF
cat > %{buildroot}/etc/vimrc <<- "EOF"
	" Begin .vimrc
	set columns=80
	set wrapmargin=8
	set ruler
	" End .vimrc
EOF
cat > %{buildroot}/etc/skel/.vimrc <<- "EOF"
	" Begin .vimrc
	set columns=80
	set wrapmargin=8
	set ruler
	" End .vimrc
EOF
cat > %{buildroot}/etc/skel/.bash_profile <<- "EOF"
# Begin ~/.bash_profile
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>
# updated by Bruce Dubbs <bdubbs@linuxfromscratch.org>

# Personal environment variables and startup programs.

# Personal aliases and functions should go in ~/.bashrc.  System wide
# environment variables and startup programs are in /etc/profile.
# System wide aliases and functions are in /etc/bashrc.
	if [ -f "$HOME/.bashrc" ] ; then
	       source $HOME/.bashrc
	fi
	if [ -d "$HOME/bin" ] ; then
	       pathprepend $HOME/bin
	fi
# Having . in the PATH is dangerous
#if [ $EUID -gt 99 ]; then
#	pathappend .
#fi
# End ~/.bash_profile
EOF
cat > %{buildroot}/etc/skel/.profile <<- "EOF"
# Begin ~/.profile
# Personal environment variables and startup programs.

	if [ -d "$HOME/bin" ] ; then
	       pathprepend $HOME/bin
	fi

# Set up user specific i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>

# End ~/.profile
EOF
cat > %{buildroot}/etc/skel/.bashrc <<- "EOF"
# Begin ~/.bashrc
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal aliases and functions.

# Personal environment variables and startup programs should go in
# ~/.bash_profile.  System wide environment variables and startup
# programs are in /etc/profile.  System wide aliases and functions are
# in /etc/bashrc.
	if [ -f "/etc/bashrc" ] ; then
	       source /etc/bashrc
	fi
# Set up user specific i18n variables
#export LANG=<ll>_<CC>.<charmap><@modifiers>
# End ~/.bashrc
EOF
cat > %{buildroot}/etc/skel/.bash_logout <<- "EOF"
# Begin ~/.bash_logout
# Written for Beyond Linux From Scratch
# by James Robertson <jameswrobertson@earthlink.net>

# Personal items to perform on logout.

# End ~/.bash_logout
EOF
#----------------------------------------------------------------------------
%files 
	%defattr(-,root,root)
	%attr(600,root,root)	/var/log/btmp
	%attr(664,root,utmp)	/var/log/lastlog
	%attr(-,root,root)	/var/log/wtmp
	%attr(750,root,root)	/root
	%attr(1777,root,root)	/tmp
	%attr(1777,root,root)	/var/tmp
#	Directories
	%dir	/home
	%dir	/mnt
	%dir	/boot
	%dir	/var
	%dir	/var/log
	%dir	/var/mail
	%dir	/var/local
	%dir	/var/spool
	%dir	/var/cache
	%dir	/var/lib
	%dir	/var/lib/locate
	%dir	/var/lib/hwclock
	%dir	/var/lib/misc
	%dir	/var/lib/color
	%dir	/var/opt
	%dir	/etc
#	/etc init script directories	
	%dir	/etc/rc.d
	%dir	/etc/rc.d/init.d
	%dir	/etc/rc.d/rc0.d
	%dir	/etc/rc.d/rc1.d
	%dir	/etc/rc.d/rc2.d
	%dir	/etc/rc.d/rc3.d
	%dir	/etc/rc.d/rc4.d
	%dir	/etc/rc.d/rc5.d
	%dir	/etc/rc.d/rc6.d
	%dir	/etc/rc.d/rc7.d
		/etc/rc.d/rcS.d
	%dir	/etc/sysconfig
	%dir	/etc/ld.so.conf.d
	%dir	/etc/opt
	%dir	/etc/profile.d
	%dir	/lib64
	%dir	/usr
	%dir	/usr/src
	%dir	/usr/local
	%dir	/usr/local/src
	%dir	/usr/local/bin
	%dir	/usr/local/sbin
	%dir	/usr/local/lib
	%dir	/usr/local/share
	%dir	/usr/local/share/misc
	%dir	/usr/local/share/terminfo
	%dir	/usr/local/share/doc
	%dir	/usr/local/share/zoneinfo
	%dir	/usr/local/share/man
	%dir	/usr/local/share/man/man3
	%dir	/usr/local/share/man/man4
	%dir	/usr/local/share/man/man7
	%dir	/usr/local/share/man/man1
	%dir	/usr/local/share/man/man6
	%dir	/usr/local/share/man/man8
	%dir	/usr/local/share/man/man5
	%dir	/usr/local/share/man/man2
	%dir	/usr/local/share/locale
	%dir	/usr/local/share/dict
	%dir	/usr/local/share/color
	%dir	/usr/local/share/info
	%dir	/usr/local/include
	%dir	/usr/bin
	%dir	/usr/sbin
	%dir	/usr/lib
	%dir	/usr/libexec
	%dir	/usr/share
	%dir	/usr/share/misc
	%dir	/usr/share/terminfo
	%dir	/usr/share/doc
	%dir	/usr/share/zoneinfo
	%dir	/usr/share/man
	%dir	/usr/share/man/man3
	%dir	/usr/share/man/man4
	%dir	/usr/share/man/man7
	%dir	/usr/share/man/man1
	%dir	/usr/share/man/man6
	%dir	/usr/share/man/man8
	%dir	/usr/share/man/man5
	%dir	/usr/share/man/man2
	%dir	/usr/share/locale
	%dir	/usr/share/dict
	%dir	/usr/share/color
	%dir	/usr/share/info
	%dir	/usr/include
	%dir	/bin
	%dir	/media
	%dir	/media/floppy
	%dir	/media/cdrom
	%dir	/sbin
	%dir	/srv
	%dir	/lib
	%dir	/lib/firmware
	%dir	/dev
	%dir	/opt
	%dir	/sys
	%dir	/proc
	%dir	/run
#	Files
	%config(noreplace)	/etc/group
	%config(noreplace)	/etc/passwd
	%config(noreplace)	/etc/fstab
	%config(noreplace)	/etc/hostname
	%config(noreplace)	/etc/hosts
	%config(noreplace)	/etc/inittab
	%config(noreplace)	/etc/inputrc
	%config(noreplace)	/etc/lfs-release
	%config(noreplace)	/etc/lsb-release
	%config(noreplace)	/etc/modprobe.d/usb.conf
	%config(noreplace)	/etc/resolv.conf
	%config(noreplace)	/etc/shells
	%config(noreplace)	/etc/sysconfig/clock
	%config(noreplace)	/etc/sysconfig/ifconfig.eth0
	%config(noreplace)	/etc/mtab
	%config(noreplace)	/var/log/faillog
	%config(noreplace)	/var/lock
	%config(noreplace)	/var/run
#-----------------------------------------------------------------------------
#	BLFS scripts	-	About System Users and Groups
#-----------------------------------------------------------------------------
	%config(noreplace)	/etc/bashrc
	%config(noreplace)	/etc/profile
	%config(noreplace)	/etc/vimrc
	%config(noreplace)	/etc/profile.d/bash_completion.sh
	%config(noreplace)	/etc/profile.d/dircolors.sh
	%config(noreplace)	/etc/profile.d/extrapaths.sh
	%config(noreplace)	/etc/profile.d/i18n.sh
	%config(noreplace)	/etc/profile.d/readline.sh
	%config(noreplace)	/etc/profile.d/umask.sh
	%config(noreplace)	/etc/skel/.bash_logout
	%config(noreplace)	/etc/skel/.bash_profile
	%config(noreplace)	/etc/skel/.bashrc
	%config(noreplace)	/etc/skel/.profile
	%config(noreplace)	/etc/skel/.vimrc
#-----------------------------------------------------------------------------
%changelog
*	Thu Mar 14 2019 baho-utot <baho-utot@columbus.rr.com> 8.4-1
*	Sun Oct 28 2018 baho-utot <baho-utot@columbus.rr.com> 8.2-1
*	Tue Dec 12 2017 baho-utot <baho-utot@columbus.rr.com> 8.1-1
-	Update to LFS-8.1
*	Tue Jun 17 2014 baho-utot <baho-utot@columbus.rr.com> 7.5-1
*	Fri Apr 19 2013 baho-utot <baho-utot@columbus.rr.com> 20130401-1
-	Upgrade version
