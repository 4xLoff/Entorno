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

function script(){
        echo -e "${greenColour}The Bspwn environment will be installed.${endColour}"
        sleep 3
        echo -e "${greenColour}Update system.${endColour}"
        sudo apt update && sudo apt -y full-upgrade
        echo -e "${greenColour}Install core dependencies.${endColour}"
        apt install -y build-essential git vim libxcb-util0-dev libxcb-ewmh-dev libxcb-randr0-dev libxcb-icccm4-dev libxcb-keysyms1-dev libxcb-xinerama0-dev libasound2-dev libxcb-xtest0-dev libxcb-shape0-dev libxcb-xtest0-dev libxcb-shape0-dev
        echo -e "${greenColour}Install polybar dependecies.${endColour}"
        apt install -y cmake cmake-data pkg-config python3-sphinx libcairo2-dev libxcb1-dev libxcb-util0-dev libxcb-randr0-dev libxcb-composite0-dev python3-xcbgen xcb-proto libxcb-image0-dev libxcb-ewmh-dev libxcb-icccm4-dev libxcb-xkb-dev libxcb-xrm-dev libxcb-cursor-dev libasound2-dev libpulse-dev libjsoncpp-dev libmpdclient-dev libuv1-dev libnl-genl-3-dev polybar 
        echo -e "${greenColour}Install picom dependencies.${endColour}"
        apt install -y meson libxext-dev libxcb1-dev libxcb-damage0-dev libxcb-xfixes0-dev libxcb-shape0-dev libxcb-render-util0-dev libxcb-render0-dev libxcb-randr0-dev libxcb-composite0-dev libxcb-image0-dev libxcb-present-dev libxcb-xinerama0-dev libpixman-1-dev libdbus-1-dev libconfig-dev libgl1-mesa-dev libpcre2-dev libevdev-dev uthash-dev libev-dev libx11-xcb-dev libxcb-glx0-dev 
        echo -e "${greenColour}Move files configuration.${endColour}"
        mkdir "/home/$USER/.config/bspwm"
        mkdir "/home/$USER/.config/sxhkd"
        cp -r "/home/$USER/Downloads/Entorno/picom" ~/.config/
        cp -r ~/Downloads/Entorno/kitty ~/.config/
        cp -r ~/Downloads/Entorno/rofi ~/.config/
        cp -r ~/Downloads/Entorno/polybar ~/.config/
        cp -r ~/Downloads/Entorno/.p10k.zsh "/home/$USER/"
        cp -r ~/Downloads/Entorno/.zshrc "/home/$USER/"
        chmod +x ~/.config/bspwm/bspwmrc
        chmod +x ~/.config/bspwm/scripts/bspwm_resize
        chmod +x ~/.config/polybar/launch.sh
        echo -e "${greenColour}Polybar compilation .${endColour}"
        git clone --recursive https://github.com/polybar/polybar
        cd polybar/
        mkdir build
        cd build/
        cmake ..
        make -j$(nproc)
        sudo make install
        echo -e "${greenColour}Download powerlevel10k.${endColour}"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ~/powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
        echo -e "${greenColour}Install Hack Nerd Fonts.${endColour}" 
        wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.2.2/Hack.zip
        unzip Hack.zip > /dev/null 2>&1 && sudo mv *.ttf /usr/local/share/fonts/
        rm Hack.zip LICENSE.md readme.md
        echo -e "${greenColour}Configuration wallpaper.${endColour}"
        cp -r ~/Downloads/Entorno/3.png ~/Pictures/
        echo -e "${greenColour}Install plugin sudo.${endColour}"
        wget https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
        sudo cp sudo.plugin.zsh /usr/share/zsh-plugins/
        echo -e "${greenColour}Install fzf.${endColour}"
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        ~/.fzf/install --all
        git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
        ~/.fzf/install --all &>/dev/null
        sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
        sudo ~/.fzf/install --all
        sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
        sudo ~/.fzf/install --all &>/dev/null
        echo -e "${greenColour}Install nvcahd.${endColour}"
        rm -rf ~/.config/nvim
        pushd /opt &>/dev/null && sudo wget -q https://github.com/neovim/neovim/releases/download/v0.9.5/nvim-linux64.tar.gz && sudo tar -xf nvim-linux64.tar.gz; popd &>/dev/null
        git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1
        git clone https://github.com/NvChad/NvChad ~/.config/nvim --depth 1 &>/dev/null
        sudo rm -rf /root/.config/nvim
        sudo git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1
        sudo git clone https://github.com/NvChad/NvChad /root/.config/nvim --depth 1 &>/dev/null
        ln -s -f /opt/nvim-linux64/bin/nvim /usr/bin/
        sudo rm -f /opt/nvim-linux64.tar.gz
        echo -e "${greenColour}Install spotify.${endColour}"
        sudo apt install playerctl -y
        git clone https://github.com/noctuid/zscroll
        cd zscroll
        sudo python3 setup.py install
        echo -e "${greenColour}Create links.${endColour}"
        ln -s -f ~/.zshrc /root/.zshrc
        ln -s -f ~/.p10k.zsh /root/.p10k.zsh
        usermod --shell /usr/bin/zsh $USER
        usermod --shell /usr/bin/zsh root
        chown $USER:$USER /root
        chown $USER:$USER /root/.cache -R
        chown $USER:$USER /root/.local -R

}

function hacker(){
         echo -e "${greenColour}The latex environment will be installed, this will take more than 30 minutes approximately..${endColour}"
         sleep 3
         apt install latexmk zathura rubber texlive-full -y --fix-missing
         cd /home/$USER/Downloads
         wget https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.8/obsidian_1.5.8_amd64.deb
         sudo dpkg -i obsidian_1.5.8_amd64.deb
}

function other(){
        echo -e "${greenColour}Additional packages will be installed for the correct functioning of the environment.${endColour}"
        sleep 3
        cd ..
        sudo apt install -y feh scrot scrub zsh rofi xclip locate neofetch acpi bspwm sxhkd imagemagick code kitty ranger i3lock-fancy  wmname firejail cmatrix htop python3-pip procps tty-clock fzf lsd bat pamixer flameshot python3 gcc g++ libfreetype6-dev libglib2.0-dev libcairo2-dev meson pkg-config gtk-doc-tools zlib1g-dev libpng16-16 liblcms2-2 librsync-dev libssl-dev libfreetype6 libfreetype6-dev fontconfig imagemagick ffuf pkg-config libdbus-1-dev libxcursor-dev libxrandr-dev libxi-dev libxinerama-dev libgl1-mesa-dev libxkbcommon-x11-dev libfontconfig1-dev libx11-xcb-dev liblcms2-dev libssl-dev libpython3-dev libharfbuzz-dev wayland-protocols libxxhash-dev bc zsh-syntax-highlighting ranger seclists
}

function session(){
        echo -ne "\n\t${redColour} We are closing the session to apply the new configuration.${endColour}" && read a
        sleep 20 & while [ "$(ps a | awk '{print $1}' | grep $!)" ] ; do for X in '-' '\' '|' '/'; do echo -en "\b$X"; sleep 0.1; done; done
        kill -9 -1

}

function clean(){
        echo -ne "\n\t${purpleColour} We are cleaning everything$.{endColour}" && read a
        sleep 3
        rm -rf "$HOME/Downloads/"
        sudo apt autoremove -y
}

function helpPanel(){
  echo -e "\n${greenColour}[!] Uso: sudo $0 -i ${endColour}"
  echo -e "\n\t${blueColour}[-i] Version install.${endColour}"
  echo -e "\n\t\t${turquoiseColour} scriptMode${endColour}\t\t${yellowColour} Basic installation (bspwn + polyvar + picom + powerlevelk + kitty + zsh)${endColour}"
  echo -e "\n\t\t${purpleColour} hackerMode${endColour}\t\t${yellowColour} Full installation (Bascic intallation + obsidian + vsc + spotify + latex)${endColour}"
  echo -e "\n\t${redColour}[-h] Show help panel.${endColour}"
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
    other
    script
    clean
    #session
  elif [ $(echo $Mode) == "hackerMode" ]; then
    other
    #script
    #hacker
    #clean
  else
    echo -e "${redColour}[!] Invalid options${endColour}"
    tput cnorm; exit 1
  fi
fi
