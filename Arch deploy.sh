#!/bin/sh
# Authored by @DaLemonBoi on GitHub.
# Deploy Arch/Artix system script.

unset response WHILE_VAR NORMALUSER HOMENORMAL NOTAU actuid DRIVER_VAR # Make sure there is no conflicting variables.

if [[ $EUID -ne 0 ]]; then # Checks if running with root privileges and exits if not.
   echo "Please run with root privileges" 1>&2
   exit 1
fi
echo "Running deploy script..."
sleep 1
echo "Installing necessary programs..."
sleep .5
yes | pacman --quiet -Syyu # Updates and upgrades.
yes | pacman --quiet -S xorg gnome-shell gnome-tweaks nautilus lightdm lightdm-webkit2-greeter zsh firefox dash # Installs necessary packages.
echo "Installing and configuring lightdm..."
git clone git clone git@github.com:NoiSek/Aether.git # Clone Aether lightdm theme.
mv Aether /usr/share/lightdm-webkit/themes/Aether # Following installation instructions per the Aether theme github page.
sed -i 's/^webkit_theme\s*=\s*\(.*\)/webkit_theme = lightdm-webkit-theme-aether #\1/g' /etc/lightdm/lightdm-webkit2-greeter.conf
sed -i 's/^\(#?greeter\)-session\s*=\s*\(.*\)/greeter-session = lightdm-webkit2-greeter #\1/ #\2g' /etc/lightdm/lightdm.conf
echo "Bringing down and installing dotfiles..."
git clone https://github.com/DaLemonBoi/Dotfiles # Clones my dotfiles repository.
cd Dotfiles/rootfs
read -p "Please specify the actual name of your normal user.

> " NORMALUSER

until HOMENORMAL="$(su "$NORMALUSER" -c 'echo $HOME')"
do
    read -p "This user does not exist or does not have a home directory. Please specify your normal user's username EXACTLY how the system sees it.

> " NORMALUSER
done
mv lemon ../rootfs$HOMENORMAL
read -r -p "Do you want to install my dotfiles? This may overwrite some files if they have the same same absolute path as those from the rootfs directory so it is only recommended to do this in fresh installs.
This part can be safely skipped if you like [y/N] 

> " response
case "$response" in # Takes reponse from read command seen above and confirmes its a valid input. Runs corresponding command.
    [yY][eE][sS]|[yY]) 
        mv ../rootfs /
		sleep 1
        ;;
    *)
        echo "Okay! We'll skip this"
		sleep 1
        ;;
esac
echo "Enabling lightdm in your init system..."
case $(ps chp1 ocommand) in # Checks for init system then enables lightdm for that init system. This may fail on BSD systems.
systemd) 
systemctl enable lightdm
;;
openrc)
rc-update add lightdm
;;
runit)
ln -s /etc/runit/sv/lightdm /run/runit/service
;;
s6)
s6-rc-bundle add default lightdm
;;
*)
echo 'Unknown init system. You will have to enable lightdm for your init system. If you are sure you have either Systemd, Runit, Openrc, or S6 then please make an issue on the dalemonboi/dotfiles github page. Continuing deploy script...'
INIT_VAR="y"
sleep 3
;;
esac
echo "Linking /bin/sh to dash..."
rm /bin/sh # Remove /bin/sh symlink to allow symlink to dash shell.
ln /usr/bin/dash /bin/sh # Link /usr/bin/dash to /bin/sh to allow for better speeds when running non-interactive shell.
sleep 1
echo "Changing root and $NORMALUSER default shell to zsh..."
yes '/usr/bin/zsh' | chsh root # Change default shell to zsh for root
yes '/usr/bin/zsh' | chsh $NORMALUSER # Change default shell to zsh for normal user.
sleep 1
while [ "$WHILE_VAR" != "y" ] # While loop till valid driver name is chosen.
do
	echo "Please specify the graphics card or integrated graphics you have.\n'ati' for a older AMD card, 'amd' for an newer AMD card, 'intel' for Intel integrated graphics, and 'nvidia' for a Nvidia card. You may put 'skip' if you do not know at this time but you MUST install a graphics driver before you restart.\n"
	read -r -p "> " response
	case "$response" in # Takes reponse from read command seen above and confirmes its a valid input. Runs corresponding command.
		[aA][tT][iI]) 
			echo "Installing ati card driver..."
			sleep .5
			yes |  pacman -S xf86-video-ati mesa
			WHILE_VAR=y
			;;
		[aA][mM][dD])
			echo "Installing amd card driver..."
			sleep .5
			yes |  pacman -S xf86-video-amdgpu mesa
			WHILE_VAR=y
			;;
		[iI][nN][tT][eE][lL])
			echo "Installing intel integrated graphics driver.."
			sleep .5
			yes |  pacman -S xf86-video-intel mesa
			WHILE_VAR=y
			;;
		[nN][vV][iI][dD][iI][aA])
			echo "installing nvidia card driver..."
			sleep .5
			yes |  pacman -S xf86-video-nouveau mesa
			WHILE_VAR=y
			;;
		[sS][kK][iI][pP]|[sS])
			echo "Okay! We'll skip this. Install your driver later..."
			sleep .5
			DRIVER_VAR=y
			WHILE_VAR=y
			;;
		*)
			echo "Invalid input..."
			sleep .3
	esac
done
echo "Cleaning up..."
cd ../..
rm -rf Dotfiles # Delete Dotfiles directory
unset response WHILE_VAR NORMALUSER HOMENORMAL NOTAU actuid DRIVER_VAR # Unset uneeded variables.
sleep .5
if [ -n "$INIT_VAR" ]; then # Check if INIT_VAR is set and if so display error message.
  echo "ERROR: Your init system is not compatiable with this script. Please enable lightdm before restarting. If you are sure you have either Systemd, Runit, Openrc, or S6 then please make an issue on the dalemonboi/dotfiles github page."
else
  sleep 0
fi
if [ -n "$DRIVER_VAR" ]; then # Check if DRIVER_VAR is set and if so display correct goodbye message opposed to the other.
  echo "Deploy script finished!\nPlease install the correct graphics driver before restarting. More infomation here: <https://wiki.archlinux.org/index.php/Xorg#Driver_installation>"
else
  echo "Deploy script finished!\nYou may now restart."
fi
exit 0
