#!/bin/bash

. ./helpers.sh

## must be root
RootCheck


## begin installation

TaggedEcho "Beginning installations..."
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
	echo "      (Look for '*** FAILED ***' above)"
fi
