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
cp -r ./files/home/.config/GIMP/2.10/plug-ins/* $HOME_DIR/.config/GIMP/2.10/plug-ins/
chmod 777 $HOME_DIR/.config/GIMP/2.10/plug-ins/*
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


TaggedEcho "Installing Blender..."
apt install -y blender
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing SimpleScreenRecorder..."
apt install -y simplescreenrecorder
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing Redshift..."
apt install -y redshift-gtk
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


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


NewLine


TaggedEcho "Installing Flatpak..."
apt install -y flatpak
if [[ $? -eq 0 ]]; then
    apt install -y gnome-software-plugin-flatpak
    if [[ $? -eq 0 ]]; then
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
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


TaggedEcho "Installing OBS with Flatpak..."
flatpak install -y flathub com.obsproject.Studio
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


# ~/bin directory for app shortcuts
TaggedEcho "Creating app shortcut directory..."
mkdir $HOME_DIR/bin
if [[ $? -eq 0 ]]; then
    chmod 777 $HOME_DIR/bin
    if [[ $? -eq 0 ]]; then
#	[[ ":$PATH:" != *":$HOME_DIR:"* ]] && PATH="/path/to/add:${PATH}"
	Done
    else
	Failure
    fi
else
    Failure
fi


NewLine


# donezo
if [[ Notices -ne 0 ]]; then
    if [[ Notices -eq 1 ]]; then
	TaggedEcho "There was a NOTICE!"
    else
	TaggedEcho "There were $Notices NOTICES!"
    fi
fi

if [[ Errors -eq 0 ]]; then
    TaggedEcho "Finished with no errors! Restart to make sure startup apps work correctly."
else
    TaggedEcho "Full installation failed, there were errors."
    echo "         (Look for '*** FAILED ***' above)"
fi
TaggedEcho "If you have no audio in i3, run:"
echo "         'systemctl enable pulseaudio.service --user'"
