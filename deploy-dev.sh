#!/bin/sh
#    HyperVM, Server Virtualization GUI for OpenVZ and Xen
#
#    HyperVM, Server Virtualization GUI for OpenVZ and Xen
#
#    Copyright (C) 2000-2009       LxLabs
#    Copyright (C) 2009-2009       LxCenter
#    Copyright (C) 2009-2017       Com-QuadTech  http://com-quadtech.net | Developer
#
#    Server - Sponsoring by: https://avoro.eu  &  http://disker.net  
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#	 author: Ángel Guzmán Maeso <angel.guzman@lxcenter.org>
#
#    Install and deploy a develoment version on a local enviroment
#
#    Version 0.7 Added local [ Siegfried Sbrzesny <siegfried.sbrzesny@t-online.de> ]
#    Version 0.6 Added local [ Krzysztof Taraszka <krzysztof.taraszka@hypervm-ng.org> ]
#    Version 0.5 Added legacy & NG [ Krzysztof Taraszka <krzysztof.taraszka@hypervm-ng.org> ]
#    Version 0.4 Added which, zip and unzip as requirement [ Danny Terweij <d.terweij@lxcenter.org> ]
#    Version 0.3 Added perl-ExtUtils-MakeMaker as requirement to install_GIT [ Danny Terweij <d.terweij@lxcenter.org> ]
#    Version 0.2 Changed git version [ Danny Terweij <d.terweij@lxcenter.org> ]
#    Version 0.1 Initial release [ Ángel Guzmán Maeso <angel.guzman@lxcenter.org> ]
#
HYPERVM_PATH='/usr/local/lxlabs'

usage(){
    echo "Usage: $0 [BRANCH] [-h]"
    echo 'BRANCH: master, legacy, dev or local'
    echo 'h: shows this help.'
    exit 1
}

install_GIT()
{
	# Redhat based
	if [ -f /etc/redhat-release ] ; then
		# Install git with curl and expat support to enable support on github cloning
		yum install -y gcc gettext-devel expat-devel curl-devel zlib-devel openssl-devel perl-ExtUtils-MakeMaker
	# Debian based
	elif [ -f /etc/debian_version ] ; then
		# No tested
		apt-get install gcc
	fi
	
	# @todo Try to get the lastest version from some site. LATEST file?
	GIT_VERSION='1.8.3.4'
	
	echo "Downloading and compiling GIT ${GIT_VERSION}"
	wget http://git-core.googlecode.com/files/git-${GIT_VERSION}.tar.gz
	tar xvfz git-*.tar.gz; cd git-*;
	./configure --prefix=/usr --with-curl --with-expat
	make all
	make install
	
	echo 'Cleaning GIT files.'
	cd ..; rm -rf git-*
}

require_root()
{
	if [ `/usr/bin/id -u` -ne 0 ]; then
    	echo 'Please, run this script as root.'
    	usage
	fi
}

require_requirements()
{
    #
    # without them, it will compile each run git and does not create/unzip the development files.
    #
    yum -y install which zip unzip
}


require_root

require_requirements

echo 'Installing HyperVM-Com-QuadTech.net development version.'

if which git >/dev/null; then
	echo 'GIT support detected.'
else
    echo 'No GIT support detected. Installing GIT.'
    install_GIT
fi

case $1 in 
	master )
		# Clone from GitHub the last version using git transport (no http or https)
		echo "Installing branch hypervm/master"
		mkdir -p ${HYPERVM_PATH}
		git clone https://github.com/hypervm-ng/hypervm-ng.git ${HYPERVM_PATH}
		cd ${HYPERVM_PATH}
		git checkout master
		cd ${HYPERVM_PATH}/hypervm-install
		sh ./make-distribution.sh
		cd ${HYPERVM_PATH}/hypervm
		sh ./make-development.sh
		printf "Done.\nInstall HyperVM-NG:\ncd ${HYPERVM_PATH}/hypervm-install/hypervm-linux/\nsh hypervm-install-[master|slave].sh with args\n"
		;;
	legacy )
		# Clone from GitHub the last version using git transport (no http or https)
		echo "Installing branch hypervm/legacy"
		mkdir -p ${HYPERVM_PATH}
		git clone https://github.com/hypervm-ng/hypervm-ng.git ${HYPERVM_PATH}
		cd ${HYPERVM_PATH}
		git checkout legacy
		cd ${HYPERVM_PATH}/hypervm-install
		sh ./make-distribution.sh
		cd ${HYPERVM_PATH}/hypervm
		sh ./make-development.sh
		printf "Done.\nInstall HyperVM-NG:\ncd ${HYPERVM_PATH}/hypervm-install/hypervm-linux/\nsh hypervm-install-[master|slave].sh with args\n"
		;;
	dev )
		# Clone from GitHub the last version using git transport (no http or https)
		echo "Installing branch hypervm/dev"
		git clone https://github.com/hypervm-ng/hypervm-ng.git ${HYPERVM_PATH}
		cd ${HYPERVM_PATH}
		git checkout dev -f
		cd ${HYPERVM_PATH}/hypervm-install
		sh ./make-distribution.sh
		cd ${HYPERVM_PATH}/hypervm
		sh ./make-development.sh
		printf "Done.\nInstall HyperVM-NG:\ncd ${HYPERVM_PATH}/hypervm-install/hypervm-linux/\nsh hypervm-install-[master|slave].sh with args\n"
		;;
	local )
		# Clone from GitHub the last version using git transport (no http or https)
		echo "Installing local branch of hypervm"
        if [ ! -f ${HYPERVM_PATH}/.git ]
        then
    		touch ${HYPERVM_PATH}/.git
    	fi
		cd hypervm-install
		sh ./make-distribution.sh
		cd ..//hypervm
		sh ./make-development.sh
		cp hypervm-current.zip ${HYPERVM_PATH}/hypervm
		printf "Done.\nInstall HyperVM-NG:\ncd hypervm-install/hypervm-linux/\nsh hypervm-install-[master|slave].sh with args\n"
		;;

	*   )
		usage
		return 1 ;;
esac
