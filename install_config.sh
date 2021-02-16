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

TaggedEcho "Beginning configuration..."
apt update

NewLine


TaggedEcho "Disabling mouse acceleration..."
mkdir -p /usr/share/X11/xorg.conf.d/
cp -r ./files/root/usr/share/X11/xorg.conf.d/50-mouse-acceleration.conf /usr/share/X11/xorg.conf.d/
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing htop..."
apt install -y htop
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing i3wm..."
sudo apt install -y i3
if [[ $? -eq 0 ]]; then
	mkdir -p $HOME_DIR/.config/i3
    cp -r ./files/home/.config/i3/* $HOME_DIR/.config/i3/
    if [[ $? -eq 0 ]]; then
		Done
    else
		Failure
    fi
else
    Failure
fi
TaggedEcho "Installing i3blocks..."
sudo apt install -y i3blocks
if [[ $? -eq 0 ]]; then
	Done
else
	Failure
fi


NewLine


TaggedEcho "Installing xterm..."
sudo apt install -y xterm
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing Rofi..."
sudo apt install -y rofi
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine


TaggedEcho "Installing feh and wallpapers..."
sudo apt install -y feh
if [[ $? -eq 0 ]]; then
    cp -r ./files/home/Pictures $HOME_DIR/
    if [[ $? -eq 0 ]]; then
	cp -r ./files/home/.config/.fehbg $HOME_DIR/.config/
	if [[ $? -eq 0 ]]; then
	    if [[ -f "/var/spool/cron/crontabs/$USER_NAME" ]]; then
			Notice
			TaggedEcho "Didn't create crontab, make sure feh job got added!"
	    else
			touch /var/spool/cron/crontabs/$USER_NAME
			if [[ $? -eq 0 ]]; then
			    crontab -u $USER_NAME -l > ./temp_cron
			    if [[ $? -eq 0 ]]; then
					DISPLAY_VAR="$(env | grep -i display)"
					echo "0 */1 * * * $DISPLAY_VAR $HOME_DIR/.config/.fehbg" >> temp_cron
					if [[ $? -eq 0 ]]; then
					    crontab -u $USER_NAME temp_cron
					    if [[ $? -eq 0 ]]; then
							rm temp_cron
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
			    else
					Failure
			    fi
			else
			    Failure
			fi
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


NewLine


TaggedEcho "Installing ranger with image previews..."
apt install -y ranger
if [[ $? -eq 0 ]]; then
    TaggedEcho "ranger installed successfully"
    TaggedEcho "Installing w3m..."
    apt install -y w3m-img
    if [[ $? -eq 0 ]]; then
		mkdir -p $HOME_DIR/.config/ranger
		touch $HOME_DIR/.config/ranger/rc.conf
	    if [[ $? -eq 0 ]]; then
			echo -e "\nset preview_images true" >> $HOME_DIR/.config/ranger/rc.conf
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
else
    Failure
fi


NewLine


TaggedEcho "Installing fonts..."
cp -r ./files/home/.fonts $HOME_DIR
if [[ $? -eq 0 ]]; then
	chmod 777 $HOME_DIR/.fonts
    Done
else
    Failure
fi

TaggedEcho "Installing FontAwesome..."
apt install -y fonts-font-awesome
if [[ $? -eq 0 ]]; then
    Done
else
    Failure
fi


NewLine





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
    TaggedEcho "Finished with no errors! Reboot to complete configuration."
    echo "         (Don't forget to select i3 as your desktop)"
else
    TaggedEcho "Configuration not fully complete, there were errors."
    echo "         (Look for '*** FAILED ***' above)"
fi
