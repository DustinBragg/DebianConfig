#!/bin/bash

. ./helpers.sh

## must be root
RootCheck


## begin installation

TaggedEcho "Beginning installations..."
apt update


NewLine


# ~/bin directory for app shortcuts
TaggedEcho "Creating app shortcut directory..."
mkdir -p $HOME_DIR/bin
if [[ $? -eq 0 ]]; then
    chmod 777 $HOME_DIR/bin
    if [[ $? -eq 0 ]]; then
	grep -qxF "export PATH=\"${PATH}:${HOME_DIR}/bin\"" $HOME_DIR/.bashrc || echo "export PATH=\"${PATH}:${HOME_DIR}/bin\""	 >> $HOME_DIR/.bashrc
	if [[ $? -eq 0 ]]; then
	    if [[ $? -eq 0 ]]; then
		grep -qxF "PATH=\"${PATH}:${HOME_DIR}/bin\"" $HOME_DIR/.profile || echo "PATH=\"${PATH}:${HOME_DIR}/bin\"" >> 		$HOME_DIR/.profile
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
else
    Failure
fi

# copy our bin files over
TaggedEcho "Copying custom app shortcuts..."
cp -r ./files/home/bin/* $HOME_DIR/bin/
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
GIMPVersion=$(gimp --version | grep -Po '\d+(\.\d+)')
mkdir -p $HOME_DIR/.config/GIMP/$GIMPVersion/plug-ins/
cp -r ./files/home/.config/GIMP/$GIMPVersion/plug-ins/* $HOME_DIR/.config/GIMP/$GIMPVersion/plug-ins/
chmod +x $HOME_DIR/.config/GIMP/$GIMPVersion/plug-ins/*
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


TaggedEcho "Installing Emacs..."
apt install -y emacs
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


## NOTE: This is not the latest revamped-UI version of Blender on Debian < 11.
##	   Disabling this for now because we go grab that ourselves.
##
#TaggedEcho "Installing Blender..."
#apt install -y blender
#if [[ $? -eq 0 ]]; then
#	Done
#else
#	Failure
#fi
#
#
#NewLine


TaggedEcho "Installing SimpleScreenRecorder..."
apt install -y simplescreenrecorder
if [[ $? -eq 0 ]]; then
    Done
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


TaggedEcho "Installing KDbg..."
apt install -y kdbg
if [[ $? -eq 0 ]]; then
    Done
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
    echo "      (Look for '*** FAILED ***' above)"
fi
TaggedEcho "If you have no audio in i3, run:"
echo "      'systemctl enable pulseaudio.service --user'"
