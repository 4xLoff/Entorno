#!/usr/bin/env bash

# Author: Jhon Carlos Lara (aka 4xL)

# Colours
greenColour="\e[0;32m\033[1m"
endColour="\033[0m\e[0m"
redColour="\e[0;31m\033[1m"
blueColour="\e[0;34m\033[1m"
yellowColour="\e[0;33m\033[1m"
purpleColour="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
grayColour="\e[0;37m\033[1m"

export DEBIAN_FRONTEND=noninteractive

trap ctrl_c INT

function ctrl_c(){
        echo -e "\n\n${redColour}[!] Exiting...\n${endColour}"
        tput cnorm; exit 1
}

function check(){
  if [ "$(id -u)" == "0" ] && [ -z "$SUDO_USER" ]; then
    echo -e "\n${redColour}[!]Do not run this script as root${endColour}\n"
    tput cnorm; exit 1
  fi
}

function script(){
        echo -e "${greenColour}The Bspwn environment will be installed.${endColour}"
        sleep 3
        echo -e "${greenColour}Install core dependencies.${endColour}"
        apt install -y build-essential git vim libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev libxcb-xtest0-dev libxcb-shape0-dev
        echo -e "${greenColour}Install polybar dependecies.${endColour}"
        apt install -y cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev polybar 
        echo -e "${greenColour}Install picom dependencies.${endColour}"
        apt install -y meson libxext-dev libxcb1-dev libxcb-damage0-dev framebuffer libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev 
        echo -e "${greenColour}Install bspwn and sxhkd.${endColour}"
        cd /home/$SUDO_USER/Downloads/
        git clone https://github.com/baskerville/bspwm.git
        git clone https://github.com/baskerville/sxhkd.git
        cd bspwm/
        make
        sudo make install
        cd ../sxhkd/
        make
        sudo make install        
        echo -e "${greenColour}Move files configuration.${endColour}"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/bspwm" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/sxhkd" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/picom" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/kitty" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/rofi" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/polybar" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.p10k.zsh" "/home/$SUDO_USER/"
        sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.zshrc" "/home/$SUDO_USER/"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/bspwm/bspwmrc"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/bspwm/scripts/bspwm_resize"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/launch.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/picom/picom.conf"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/kitty/kitty.conf"

        echo -e "${greenColour}Polybar compilation .${endColour}"
        cd /home/$SUDO_USER/Downloads
        git clone --recursive https://github.com/polybar/polybar
        cd polybar/
        mkdir build
        cd build/
        cmake ..
        make -j$(nproc)
        sudo make install
        echo -e "${greenColour}Download powerlevel10k.${endColour}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$SUDO_USER/powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
        echo -e "${greenColour}Install Hack Nerd Fonts.${endColour}"
        cd /home/$SUDO_USER/Downloads 
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.2/Hack.zip
        unzip Hack.zip > /dev/null 2>&1 && sudo mv *.ttf /usr/local/share/fonts/
        rm Hack.zip LICENSE.md readme.md
        echo -e "${greenColour}Configuration wallpaper.${endColour}"
        cd /home/$SUDO_USER/Downloads
        cp -r /home/$SUDO_USER/Downloads/Entorno/3.png /home/$SUDO_USER/Pictures/
        echo -e "${greenColour}Install plugin sudo.${endColour}"
        sudo mkdir /usr/share/zsh-sudo
        wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
        sudo cp sudo.plugin.zsh /usr/share/zsh-sudo/  
        echo -e "${greenColour}Install batcat.${endColour}"
        cd /home/$SUDO_USER/Downloads
        wget https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb
        sudo dpkg -i bat-musl_0.24.0_amd64.deb
        echo -e "${greenColour}Install lsd.${endColour}"
        cd /home/$SUDO_USER/Downloads
        wget https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd-musl_1.0.0_amd64.deb
        sudo dpkg -i lsd-musl_1.0.0_amd64.deb
        echo -e "${greenColour}Install fzf.${endColour}"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
	      ~/.fzf/install --all &>/dev/null
        sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
        sudo ~/.fzf/install --all &>/dev/null
        echo -e "${greenColour}Install nvcahd.${endColour}"
        rm -rf /home/$SUDO_USER/.config/nvim
        pushd /opt &>/dev/null && sudo wget -q https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz && sudo tar -xf nvim-linux64.tar.gz; popd &>/dev/null
        git clone https://github.com/NvChad/NvChad /home/$SUDO_USER/.config/nvim --depth 1
        git clone https://github.com/NvChad/NvChad /home/$SUDO_USER/.config/nvim --depth 1 &>/dev/null
        sudo rm -rf /root/.config/nvim
        sudo git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1
        sudo git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1 &>/dev/null
        ln -s -f /opt/nvim-linux64/bin/nvim /usr/bin/
        sudo rm -f /opt/nvim-linux64.tar.gz
        echo -e "${greenColour}Install spotify.${endColour}"
        sudo apt install playerctl -y
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt-get update && sudo apt-get install spotify-client
        cd /home/$SUDO_USER/Downloads
        git clone https://github.com/noctuid/zscroll
        cd zscroll
        sudo python3 setup.py install
        chmod +x /home/$SUDO_USER/.config/polybar/forest/scripts/scroll_spotify_status.sh
        chmod +x /home/$SUDO_USER/.config/polybar/forest/scripts/get_spotify_status.sh
        chmod +x /home/$SUDO_USER/.config/polybar/forest/scripts/target.sh
        echo -e "${greenColour}Create links.${endColour}"
        ln -s -f /home/$SUDO_USER/.zshrc /root/.zshrc
        ln -s -f /home/$SUDO_USER/.p10k.zsh /root/.p10k.zsh
        usermod --shell /usr/bin/zsh $SUDO_USER
        usermod --shell /usr/bin/zsh $USER
        sudo chown -R "$SUDO_USER:$SUDO_USER" "/root"
        sudo chown -R "$SUDO_USER:$SUDO_USER" "/root/.cache"
        sudo chown -R "$SUDO_USER:$SUDO_USER" "/root/.local"
}

function hacker(){
         echo -e "${greenColour}The latex environment will be installed, this will take more than 30 minutes approximately..${endColour}"
         sleep 3
         apt install latexmk zathura rubber texlive-full -y --fix-missing
         cd /home/$SUDO_USER/Downloads
         wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.8/obsidian_1.5.8_amd64.deb
         sudo dpkg -i obsidian_1.5.8_amd64.deb
}

function other(){       
        echo -e "${greenColour}Update system.${endColour}"
        cd /home/$SUDO_USER/Downloads
        echo "console-setup   console-setup/charmap47   select  Guess optimal character set" | sudo debconf-set-selections
        sudo apt update && sudo apt upgrade -y
        echo -e "${greenColour}Additional packages will be installed for the correct functioning of the environment.${endColour}"
        sleep 3
        sudo apt install -y feh scrot scrub zsh rofi xclip locate neofetch acpi bspwm sxhkd imagemagick snap caja kitty ranger i3lock-fancy wmname firejail cmatrix htop python3-pip procps tty-clock fzf pamixer flameshot python3 gcc g++ libfreetype6-dev libglib2.0-dev libcairo2-dev meson pkg-config gtk-doc-tools zlib1g-dev libpng16-16 liblcms2-2 librsync-dev libssl-dev libfreetype6 libfreetype6-dev fontconfig imagemagick ffuf pkg-config libdbus-1-dev libxcursor-dev libxrandr-dev libxi-dev libxinerama-dev libgl1-mesa-dev libxkbcommon-x11-dev libfontconfig1-dev libx11-xcb-dev liblcms2-dev libssl-dev libpython3-dev libharfbuzz-dev wayland-protocols libxxhash-dev bc zsh-syntax-highlighting ranger seclists
}

function session(){
        echo -ne "\n\t${redColour} We are closing the session to apply the new configuration, be sure to select the BSPWN.${endColour}" 
        sleep 5
        kill -9 -1
}

function clean(){
        echo -ne "\n\t${purpleColour} We are cleaning everything.${endColour}"
        rm -rf "/home/$SUDO_USER/Downloads/*"
        sudo apt autoremove -y
}

function helpPanel(){
        echo -e "\n${greenColour}[!] Uso: sudo $0 -i ${endColour}"
        echo -e "\n\t${blueColour}[-i] Version install.${endColour}"
        echo -e "\n\t\t${turquoiseColour} scriptMode${endColour}\t\t${yellowColour} Basic installation (bspwn + polyvar + picom + powerlevelk + kitty + zsh)${endColour}"
        echo -e "\n\t\t${purpleColour} hackerMode${endColour}\t\t${yellowColour} Full installation (Bascic intallation + obsidian + vsc + spotify + latex)${endColour}"
        echo -e "\n\t${redColour}[-h] Show help panel.${endColour}"
        tput cnorm; exit 1
}

declare -i parameter_counter=0; while getopts ":i:h:" arg; do

case $arg in
    i) Mode=$OPTARG; let parameter_counter+=1;;
    h) helpPanel;;
  esac
done

tput civis

if [ $parameter_counter -eq 0 ]; then
  helpPanel
else
  if [ $(echo $Mode) == "scriptMode" ]; then
    check
    other
    script
    clean
    session
  elif [ $(echo $Mode) == "hackerMode" ]; then
    check
    other
    script
    hacker
    clean
    session
  else
    echo -e "${redColour}[!] Invalid options${endColour}"
    tput cnorm; exit 1
  fi
fi
