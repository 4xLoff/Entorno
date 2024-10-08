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

function other(){       
        echo -e "${greenColour}Update system.${endColour}"
        sudo -u "$SUDO_USER" mkdir -p /home/$SUDO_USER/Downloads
        sudo -u "$SUDO_USER" mv /home/$SUDO_USER/Entorno /home/$SUDO_USER/Downloads/
        cd /home/$SUDO_USER/Downloads
        sudo apt update 
        echo -e "${greenColour}Additional packages will be installed for the correct functioning of the environment.${endColour}"
        sleep 3
        sudo apt install build-essential libpcre3-dev fontconfig libcanberra-gtk-module libpng16-16 libglib2.0-dev liblcms2-2 libxcursor-dev libxrandr-dev libxi-dev libxinerama-dev libxkbcommon-x11-dev libfontconfig1-dev libharfbuzz-dev wayland-protocols libxxhash-dev librsync-dev zsh-syntax-highlighting bc libpython3-dev python3 davtest ranger seclists imagemagick rofi caja gcc ffuf kitty bspwm feh xclip flameshot vim libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev meson libxext-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-present-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev -y
}

#BaseInstalation
function script(){
        echo -e "${greenColour}The Bspwn environment will be installed.${endColour}"
        sleep 3
        echo -e "${greenColour}Install bspwn and sxhkd.${endColour}"
        cd /home/$SUDO_USER/Downloads/
        #CloneRepo
        git clone https://github.com/baskerville/bspwm.git
        git clone https://github.com/baskerville/sxhkd.git
        cd bspwm/
        make
        sudo make install
        cd ../sxhkd/
        make
        sudo make install    
        #ConfigurationPolyvar
        echo -e "${greenColour}Configure polybar fonts.${endColour}"
        cd /home/$SUDO_USER/Downloads
        git clone https://github.com/VaughnValle/blue-sky.git
        cd /home/$SUDO_USER/Downloads/blue-sky/polybar/
        sudo cp * -r /home/$SUDO_USER/.config/polybar
        cd fonts
        sudo cp * /usr/share/fonts/truetype/
        pushd /usr/share/fonts/truetype &>/dev/null 
        fc-cache -v
        popd &>/dev/null
        echo -e "${greenColour}Picom compilation.${endColour}"
        cd /home/$SUDO_USER/Downloads
        git clone https://github.com/ibhagwan/picom.git
        cd picom/
        git submodule update --init --recursive
        meson --buildtype=release . build
        ninja -C build
        sudo ninja -C build install
        #InstallPolybarCompilation
        echo -e "${greenColour}Polybar compilation .${endColour}"
        cd /home/$SUDO_USER/Downloads
        git clone --recursive https://github.com/polybar/polybar
        cd polybar/
        mkdir build
        cd build/
        cmake ..
        make -j$(nproc)
        sudo make install
        #CopyFiles    
        echo -e "${greenColour}Move files configuration.${endColour}"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/bspwm" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/sxhkd" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/picom" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/kitty" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/rofi" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/polybar" "/home/$SUDO_USER/.config/"
        sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.p10k.zsh" "/home/$SUDO_USER/"
        sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.zshrc" "/home/$SUDO_USER/"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/sxhkd/sxhkdrc"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/bspwm/bspwmrc"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/bspwm/scripts/bspwm_resize"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/launch.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/picom/picom.conf"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/kitty/kitty.conf"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/launch.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/preview.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/launch.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/scroll_spotify_status.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/get_spotify_status.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/target.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/checkupdates"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/launcher.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/powermenu.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/style-switch.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/styles.sh"
        sudo -u "$SUDO_USER" chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/updates.sh"
        #InstallPower
        echo -e "${greenColour}Download powerlevel10k.${endColour}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$SUDO_USER/powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
        #InstallFonts
        echo -e "${greenColour}Install Hack Nerd Fonts.${endColour}"
        cd /home/$SUDO_USER/Downloads 
        sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
        sudo unzip Hack.zip > /dev/null 2>&1 && sudo mv *.ttf /usr/local/share/fonts/
        sudo rm Hack.zip LICENSE.md README.md *.ttf
        pushd /usr/local/share/fonts/
        fc-cache -v
        popd
        #InstallWallpaper
        echo -e "${greenColour}Configuration wallpaper.${endColour}"
        cd /home/$SUDO_USER/Downloads
        sudo -u "$SUDO_USER" mkdir -p /home/$SUDO_USER/Pictures
        sudo cp -r /home/$SUDO_USER/Downloads/Entorno/3.png /home/$SUDO_USER/Pictures
        echo -e "${greenColour}Install plugin sudo.${endColour}"
        sudo mkdir /usr/share/zsh-sudo
        sudo wget -q https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
        sudo cp sudo.plugin.zsh /usr/share/zsh-sudo/  
        #InstallBatcat
        echo -e "${greenColour}Install batcat.${endColour}"
        cd /home/$SUDO_USER/Downloads
        sudo wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb
        sudo dpkg -i bat-musl_0.24.0_amd64.deb
        #InstallLSD
        echo -e "${greenColour}Install lsd.${endColour}"
        cd /home/$SUDO_USER/Downloads
        sudo wget -q https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd-musl_1.0.0_amd64.deb
        sudo dpkg -i lsd-musl_1.0.0_amd64.deb
        #Installfzf
        echo -e "${greenColour}Install fzf.${endColour}"
        sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/junegunn/fzf.git /home/$SUDO_USER/.fzf &>/dev/null
	      sudo -u "$SUDO_USER" /home/$SUDO_USER/.fzf/install --all &>/dev/null
        sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
        sudo ~/.fzf/install --all &>/dev/null
        #InstallNvchad
        echo -e "${greenColour}Install nvcahd.${endColour}"
        cd /home/$SUDO_USER/Downloads
        sudo rm -rf /home/$SUDO_USER/.config/nvim
        sudo apt remove --purge nvim -y
        sudo apt remove --purge neovim -y
        sudo apt autoremove -y
        sudo wget -q https://github.com/neovim/neovim-releases/releases/download/v0.10.1/nvim-linux64.deb 
        sudo dpkg -i nvim-linux64.deb 
        sudo -u "$SUDO_USER" git clone https://github.com/NvChad/starter /home/$SUDO_USER/.config/nvim && nvim
        sudo killall nvim
        sudo rm -rf /root/.config/nvim
        sudo git clone https://github.com/NvChad/starter /root/.config/nvim && nvim
        sudo killall nvim
        #CreateLinks
        echo -e "${greenColour}Create links.${endColour}"
        sudo ln -s -f /home/$SUDO_USER/.zshrc /root/.zshrc
        sudo ln -s -f /home/$SUDO_USER/.p10k.zsh /root/.p10k.zsh
        sudo usermod --shell /usr/bin/zsh $SUDO_USER
        sudo usermod --shell /usr/bin/zsh $USER
        sudo chown "$SUDO_USER:$SUDO_USER" "/root"
        sudo chown "$SUDO_USER:$SUDO_USER" "/root/.cache" -R
        sudo chown "$SUDO_USER:$SUDO_USER" "/root/.local" -R
}

#reporting tools
function hacker(){
         echo -e "${greenColour}The latex environment will be installed, this will take more than 30 minutes approximately..${endColour}"
         sleep 3
         apt install latexmk zathura rubber texlive-full -y --fix-missing
         cd /home/$SUDO_USER/Downloads
         wget -q https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.8/obsidian_1.5.8_amd64.deb
         sudo dpkg -i obsidian_1.5.8_amd64.deb
}

#spotify configuration
function spotify(){
        echo -e "${greenColour}Install spotify.${endColour}"
        sudo apt install playerctl -y
        curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
        echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
        sudo apt-get install spotify-client -y
        cd /home/$SUDO_USER/Downloads
        git clone https://github.com/noctuid/zscroll
        cd zscroll
        sudo python3 setup.py install
        sudo rm "/home/$SUDO_USER/.config/polybar/forest/user_modules.ini"
        sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/polybar/forest/user_modules-copia.ini" "/home/$SUDO_USER/.config/polybar/forest/user_modules.ini"
}

function clean(){
        echo -ne "\n\t${purpleColour} We are cleaning everything.${endColour}"
        sudo rm -rf /home/$SUDO_USER/Downloads/*
        sudo apt --fix-broken install -y
        sudo apt upgrade -y
        sudo apt autoremove -y
}

function session(){
        echo -ne "\n\t${redColour} We are closing the session to apply the new configuration, be sure to select the BSPWN.${endColour}" 
        sleep 5
        kill -9 -1
}

function helpPanel(){
        echo -e "\n${greenColour}[!] Uso: sudo $0 -i ${endColour}"
        echo -e "\n\t${blueColour}[-i] Version install.${endColour}"
        echo -e "\n\t\t${turquoiseColour} scriptMode${endColour}\t\t${yellowColour} Basic Installation (bspwn + polyvar + picom + powerlevelk + kitty + zsh + vsc + neovim)${endColour}"
        echo -e "\n\t\t${purpleColour} hackerMode${endColour}\t\t${yellowColour} Full Installation (Bascic intallation + obsidian + latex)${endColour}"
        echo -e "\n\t\t${yellowColour} musicMode${endColour}\t\t${yellowColour} Spotify Installation (Bascic intallation + Full Installation + Spotify)${endColour}"
        echo -e "\n\t${redColour}[-h] Show Help Panel.${endColour}"
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
  elif [ $(echo $Mode) == "musicMode" ]; then
    check
    other
    script
    hacker
    spotify
    clean
    session
  else
    echo -e "${redColour}[!] Invalid options${endColour}"
    tput cnorm; exit 1
  fi
fi