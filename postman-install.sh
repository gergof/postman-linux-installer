#!/bin/bash

# log(message, level)
function log {
	if [ "$2" == "ERROR" ]; then
		PREFIX="\e[31mE "
	elif [ "$2" == "INFO" ]; then
		PREFIX="\e[90m=> "
	else
		PREFIX="\e[32m=> "
	fi

	echo -e "${PREFIX}$1\e[0m"
}

# check_cmd(command)
function check_cmd {
	if ! command -v $1 &>/dev/null; then
		log "Command $1 not found. Please install it to continue" ERROR
		exit 1
	fi
}

# get_file(url, target)
function get_file {
	if command -v curl &>/dev/null; then
		log "Downloading using curl" INFO
		curl -SsL -o $2 $1
	elif command -v wget &>/dev/null; then
		log "Downloading using wget" INFO
		wget -O $2 $1
	else
		log "Neither curl or wget is installed. Can not download file" ERROR
	fi
}

# check if tar and arch commands are available
check_cmd "tar"
check_cmd "uname"

# install locally by default, install globally by default if root
localInstall=1
if [ $EUID -eq 0 ]; then
	localInstall=0
fi

# parse options
while getopts "hlgu" option; do
	case $option in
		h)
			echo "Usage: postman-install.sh [-l] [-g] [version]"
			echo "  version: The version to install (ex: 10.24.3) or latest. Defaults to latest"
			echo "  -l: Force local installation in the user HOME directory"
			echo "  -g: Force global installation"
			echo "  -u: Uninstall postman"
			exit
			;;
		l)
			localInstall=1
			;;
		g)
			if [ $EUID -ne 0 ]; then
				log "Needs to be executed as root to perform a global installation" ERROR
				exit 1
			fi
			localInstall=0
			;;
		u)
			if [ $localInstall -eq 1 ]; then
				log "Uninstalling postman from $HOME/.local/share/Postman"
				rm -rf $HOME/.local/share/Postman
				rm -f $HOME/.local/share/applications/postman.desktop
			else
				log "Uninstalling postman from /opt/Postman"
				rm -rf /opt/Postman
				rm -f /usr/share/applications/postman.desktop
			fi
			log "Done"
			exit
			;;
		?)
			log "Invalid parameter supplied" ERROR
			exit 1
			;;
	esac
done

shift $((OPTIND-1))

# get system architecture
arch=""
if [ "$(uname -m)" == "x86_64" ]; then
	arch="64"
elif [ "$(uname -m)" == "aarch64" ]; then
	arch="arm64"
else
	log "Unsupported architecture. Postman only support x86_64 and aarch64" ERROR
	exit 1
fi

# default to installing the latest version
version="latest"
if [ $# -eq 1 ]; then
	version="$1"
elif [ $# -ne 0 ]; then
	log "Invalid number of parameters" ERROR
	exit 1
fi

log "Installing postman version $version arch ${arch}"

log "Downloading postman tarball"
versionPath="latest"
if [ "$version" != "latest" ]; then
	versionPath="version/${version}"
fi
get_file "https://dl.pstmn.io/download/$versionPath/linux_${arch}" "/tmp/postman.tar.gz"

installDir="/opt/Postman"
if [ $localInstall -eq 1 ]; then
	installDir="$HOME/.local/share/Postman"
fi

log "Installing postman in $installDir"
if [ -d $installDir ]; then
	log "Removing existing installation" INFO
	rm -rf $installDir
fi

mkdir -p "$installDir"
tar -xzvf /tmp/postman.tar.gz --strip-components=1 -C "$installDir" > /dev/null

desktopEntryFile="/usr/share/applications/postman.desktop"
if [ $localInstall -eq 1 ]; then
	desktopEntryFile="$HOME/.local/share/applications/postman.desktop"
fi

log "Createing desktop entry in $desktopEntryFile"
cat <<__EOF__ > $desktopEntryFile
[Desktop Entry]
Encoding=UTF-8
Name=Postman
Exec=$installDir/app/Postman %U
Icon=$installDir/app/resources/app/assets/icon.png
Terminal=false
Type=Application
Categories=Development;
__EOF__

log "Cleaning up"
rm /tmp/postman.tar.gz

log "Done"
