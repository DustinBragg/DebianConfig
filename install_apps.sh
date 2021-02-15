#!/bin/bash

# must be root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root."
    exit 1
fi

Errors=0
HOME_DIR="$(pwd)/../"

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


TaggedEcho "Beginning install..."
apt update

NewLine


TaggedEcho "Installing PulseAudio Volume Control..."
sudo apt install -y pavucontrol
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing Git..."
sudo apt install -y git git-lfs
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing Clang..."
sudo apt install -y clang
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing build-essential..."
sudo apt install -y build-essential
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing Google Chrome..."
sudo apt install -y google-chrome-stable
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing Spotify..."
echo deb http://repository.spotify.com stable non-free | sudo tee /etc/apt/sources.list.d/spotify.list
if [[ $? -eq 0 ]]; then
    apt-key adv --keyserver keyserver.ubuntu.com --recv-keys D1742AD60D811D58
    apt update
    if [[ $? -eq 0 ]]; then
	apt install -y spotify-client
	if [[ $? -eq 0 ]]; then
	    Done
	else
	    Failure
	fi
    else
	Failure
    fi
else
    Failure
fi


NewLine


TaggedEcho "Installing Clementine..."
apt install -y clementine
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing GIMP..."
apt install -y gimp
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi
TaggedEcho "Installing GIMP resynthesizer plugin..."
cp -r ./files/home/.config/GIMP/2.10/plug-ins/* ../.config/GIMP/2.10/plug-ins/
chmod 777 ../.config/GIMP/2.10/plug-ins/*
if [[ $? -eq 0 ]]; then
    apt install -y gimp-python
    if [[ $? -eq 0 ]]; then
	Done
    else
	Failure
    fi
else
    Failure
fi


NewLine


TaggedEcho "Installing Flameshot..."
apt install -y flameshot
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


# donezo
if [[ Errors -eq 0 ]]; then
    TaggedEcho "Finished with no errors!"
else
    TaggedEcho "Full installation failed, there were errors."
    echo "         (Look for '*** FAILED ***' above)"
fi
TaggedEcho "If you have no audio in i3, run:"
echo "         'systemctl enable pulseaudio.service --user'"
