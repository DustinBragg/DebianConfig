#!/bin/bash

# must be root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

Errors=0
declare -i Notices=0
HOME_DIR="$(dirname $(pwd))"
USER_NAME="$(basename $HOME_DIR)"

NewLine() {
    echo ""
}

TaggedEcho() {
    echo "[CONFIG] $1"
}

Done() {
    TaggedEcho "DONE"
}

Failure() {
    Errors=1
    TaggedEcho "*** FAILED ***"
}

Notice() {
    Notices+=1
    TaggedEcho "*** NOTICE ***"
}

TaggedEcho "Beginning install..."
apt update


NewLine


TaggedEcho "Installing Steam prereqs..."
dpkg --add-architecture i386
if [[ $? -eq 0 ]]; then
    apt install -f -y libgl1-nvidia-glvnd-glx:i386
    if [[ $? -eq 0 ]]; then
		Done
    else
		Failure
    fi
else
    Failure
fi


NewLine


TaggedEcho "Installing Steam..."
wget https://cdn.cloudflare.steamstatic.com/client/installer/steam.deb
if [[ $? -eq 0 ]]; then
    apt install -f -y ./steam.deb
    if [[ $? -eq 0 ]]; then
		rm ./steam.deb
		Done
    else
		Failure
    fi
else
    Failure
fi

# donezo
if [[ Notices -ne 0 ]]; then
    if [[ Notices -eq 1 ]]; then
		TaggedEcho "There was a NOTICE!"
    else
		TaggedEcho "There were $Notices NOTICES!"
    fi
fi

if [[ Errors -eq 0 ]]; then
    TaggedEcho "Finished with no errors!"
else
    TaggedEcho "Installation failed, there were errors."
    echo "         (Look for '*** FAILED ***' above)"
fi
