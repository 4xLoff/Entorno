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

function check() {
    if [ "$(id -u)" == "0" ] && [ -z "$SUDO_USER" ] ; then
        echo -e "\n${redColour}[!] Do not run this script as root.${endColour}\n"
        echo -e "${yellowColour}Run it as a normal user with sudo privileges.${endColour}\n"
        tput cnorm; exit 1
    fi
}

function check_os() {
    sudo -u "$SUDO_USER" mkdir -p "/home/$SUDO_USER/Downloads"
    sudo find "/home/$SUDO_USER/" -type d -name "Entorno" -exec mv {} "/home/$SUDO_USER/Downloads/" \;
    cd /home/$SUDO_USER/Downloads
    sudo sed -i "s/#NR_NOTIFYD_DISABLE_NOTIFY_SEND='1'/NR_NOTIFYD_DISABLE_NOTIFY_SEND='1'/" /etc/needrestart/notify.conf
    if [[ -f /etc/os-release && $(grep -q "kali" /etc/os-release; echo $?) -eq 0 ]]; then
        echo -e "\n${yellowColour}The system is Debian or Ubuntu${endColour}\n"
	    sudo apt install curl wget git dpkg gnupg -y
        update_debian
    elif [[ -f /etc/os-release && $(grep -q "parrot" /etc/os-release; echo $?) -eq 0 || -f /etc/os-release && $(grep -q "ubuntu" /etc/os-release; echo $?) -eq 0 ]]; then
        echo -e "\n${yellowColour}The system is Debian or Ubuntu${endColour}\n"
        sudo apt install curl wget git dpkg gnupg  -y
        echo -e "${yellowColour}Add repo kali.${endColour}"
        sudo rm -f "/etc/apt/sources.list.d/kali.list"
        echo "deb http://http.kali.org/kali kali-rolling main contrib non-free" | sudo tee "/etc/apt/sources.list.d/kali.list"
        sudo curl -fsSL https://archive.kali.org/archive-key.asc | sudo gpg --dearmor -o "/etc/apt/trusted.gpg.d/kali-archive-keyring.gpg"
        sudo apt clean
        sudo apt update -y
        sudo apt upgrade -y
        update_debian
    elif [[ -f /etc/arch-release ]]; then
        echo -e "\n${yellowColour}The system is Arch Linux${endColour}\n"
        sudo pacman -S --needed git base-devel curl wget --noconfirm
        cd /home/$SUDO_USER/Downloads
        sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/paru-bin.git
        cd /home/$SUDO_USER/Downloads/paru-bin
        sudo -u "$SUDO_USER" makepkg -si --noconfirm
        cd /home/$SUDO_USER/Downloads
        sudo -u "$SUDO_USER" curl -O https://blackarch.org/starp.sh
        sudo chmod +x strap.sh
        sudo ./strap.sh
        cd /home/$SUDO_USER/Downloads
        sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/snapd.git       
        cd /home/$SUDO_USER/Downloads/snapd
        sudo -u "$SUDO_USER" makepkg -si --noconfirm
        sudo systemctl enable --now snapd.socket
        sudo systemctl restart snapd.service
        cd /home/$SUDO_USER/Downloads
        sudo -u "$SUDO_USER" git clone https://aur.archlinux.org/yay.git
        cd /home/$SUDO_USER/Downloads/yay
        sudo -u "$SUDO_USER" makepkg -si --noconfirm
        yay --version 
        sudo pacman -Syu --overwrite '*' --noconfirm
        update_arch
    else
        echo -e "\n${redColour}The system is neither Debian, Ubuntu, nor Arch Linux${endColour}\n"
    fi
}

function update_debian() {
    echo -e "${yellowColour}Installing additional packages for the correct functioning of the environment.${endColour}"
    cd /home/$SUDO_USER/Downloads 
    sudo apt remove --purge codium -y
    sudo apt remove --purge nvim -y
    sudo apt remove --purge neovim -y
    # Verificar si es Kali Linux y configurar wine
    if [[ -f /etc/os-release && $(grep -q "kali" /etc/os-release; echo $?) -eq 0 ]]; then
        echo -e "${yellowColour}Configuring wine for Kali Linux.${endColour}"
        sudo dpkg --add-architecture i386
    fi
    packages=(
        apt-transport-https autoconf  
        bc bd bspwm build-essential bzip2-doc  
        caja cifs-utils cmake cmake-data 
        derby-tools default-mysql-client dex2jar 
        dh-autoreconf djvulibre-bin encfs 
        extundelete feh flite fontconfig fuse 
        gcc-multilib gdb gimp gss-ntlmssp kitty 
        libasound2-dev libbsd-dev libbz2-dev
        libcairo2-dev libconfig-dev libcryptsetup-dev 
        libdb5.3-dev libdbus-1-dev libemail-outlook-message-perl 
        libev-dev libevdev-dev libffi-dev 
        libfontconfig1-dev libgdbm-dev libgl1-mesa-dev 
        libglib2.0-dev libharfbuzz-dev libjsoncpp-dev 
        liblcms2-2 libldap2-dev liblzma-dev 
        libmemcached-tools libmpdclient-dev libncurses5-dev 
        libncursesw5-dev libnetfilter-queue-dev 
        libnl-genl-3-dev libpcap-dev libpcre2-dev libpcre3-dev 
        libpixman-1-dev libpng16-16 libpopt-dev libprotobuf-dev 
        libproxychains4 libpst-dev libpulse-dev libpython3-dev 
        libqt5sensors5 libqt5webkit5 libreadline-dev libreoffice 
        librsync-dev libsasl2-dev libsmbclient libsqlite3-dev 
        libssl-dev libuv1-dev libx11-xcb-dev libxcb1-dev 
        libxcb-composite0-dev libxcb-cursor-dev libxcb-damage0-dev
        libxcb-ewmh-dev libxcb-glx0-dev libxcb-icccm4-dev 
        libxcb-keysyms1-dev libxcb-present-dev libxcb-randr0-dev 
        libxcb-render0-dev libxcb-render-util0-dev libxcb-shape0-dev 
        libxcb-util0-dev libxcb-xfixes0-dev libxcb-xinerama0-dev 
        libxcb-xkb-dev libxcb-xrm-dev libxcb-xtest0-dev libxcursor-dev 
        libxext-dev libxi-dev libxinerama-dev libxkbcommon-x11-dev 
        libxrandr-dev libxxhash-dev ligolo-ng locate lxc maven 
        mdbtools meson mingw-w64-tools mono-devel npm 
        pidgin pkg-config pngcrush polybar 
        protobuf-compiler pst-utils putty-tools python3 python3-dev 
        python3-impacket python3-ldap python3-ldapdomaindump 
        python3-pip python3-sphinx python3-xcbgen rofi ruby 
        ruby-dev samba scrot smbmap snap snapd 
        software-properties-common suckless-tools  
        tesseract-ocr tigervnc-viewer tnscmd10g 
        uthash-dev veil vim wayland-protocols 
        wbasic wkhtmltopdf wmis xcb-proto xclip xpdf 
        xtightvncviewer zbar-tools zlib1g-dev zsh 
        zsh-syntax-highlighting
    )
    for package in "${packages[@]}"; do
        if sudo apt install "$package" -y ;then
            echo -e "${yellowColour}The package $package has been installed correctly.${endColour}"
        else
            echo -e "${redColour}The package $package didn't install.${endColour}"
        fi
    done
    # Limpiar y actualizar la base de datos
    echo -e "${yellowColour}Cleaning up and updating package database.${endColour}"
    sudo updatedb
    echo -e "${greenColour}All packages installed successfully.${endColour}"
    sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.zshrc-debian" "/home/$SUDO_USER/.zshrc" 
    sudo ln -s -f "/home/$SUDO_USER/.zshrc" "/root/.zshrc"
}

function update_arch(){
    echo -e "${yellowColour}Additional packages will be installed for the correct functioning of the environment.${endColour}"
    cd /home/$SUDO_USER/Downloads
    # Listado único de todos los paquetes agrupados
    packages=(
        antiword autoconf bat brightnessctl 
        bspwm caja cifs-utils cmake 
        dex2jar djvulibre dmenu dotnet-sdk 
        dpkg dtnet-sdk dunst emacs eww-git exploitdb eza feh 
        firefox flite fontconfig gcc-multilib  
        geany gimp gnupg go gtkmm 
        gvfs-mtp magemagick inetutils irssi 
        jadx jgmenu jq kitty lftp libcanberra-gtk-module libconfig 
        libev libevdev libffi libgl libglib2 
        liblcms2 libldap libmemcached libpcap 
        libpng16 libpopt libprotobuf libproxychains
        proxychains libpst libreoffice librsync 
        libsasl2 libwebp libxcb libxcursor 
        libxext libxi libxinerama libxkbcommon-x11 
        libxrandr ligolo-ng lxc maim make 
        maven mesa meson mpc mpd mpv
        mutt mysql-clients ncmpcpp neovim 
        nodejs npm ntfs-3g openssh openssl 
        open-vm-tools pacman pacman-contrib 
        pamixer papirus-icon-theme 
        pdfid pdf-parser picom 
        pidgin pkg-config playerctl 
        pngcrush polkit-gnome polybar python 
        python-gobject python-ldap python-pip
        python-pipx python-sphinx 
        ranger redshift rmdbtools rofi rofi-greenclip 
        ruby rustup samba scrot simple-mtpfs skipfish 
        sudo sxhkd tdrop-git tigervnc ttf-maple 
        ueberzug uthash wayland-protocols 
        webp-pixbuf-loader wkhtmltopdf
        xcb-proto xclip xdg-user-dirs xdo xdotool 
        xf86-input-vmmouse xf86-video-intel 
        xf86-video-vmware xorg xorg-xdpyinfo 
        xorg-xinit xorg-xkill xorg-xprop 
        xorg-xrandr xorg-xsetroot xorg-xwininfo 
        xpdf xqp xsettingsd xwinwrap-0.9-bin 
        yay yazi zlib zsh zsh-syntax-highlighting
        lsd locate
    )
    for package in "${packages[@]}"; do
        if sudo pacman -S "$package" --noconfirm ;then
            echo -e "${yellowColour}The package $package has been installed correctly.${endColour}"
        else
            echo -e "${redColour}The package $package didn't install.${endColour}"
        fi
    done
    echo -e "${yellowColour}Install Tools paru${endColour}"
    sudo paru -S --skipreview tdrop-git xqp rofi-greenclip xwinwrap-0.9-bin ttf-maple i3lock-color simple-mtpfs eww-git --noconfirm
    sleep 1
    echo -e "${yellowColour}Install Tools yay${endColour}"
    sudo yay -S dpkg rustscan
    echo -e "${yellowColour}Install Tools snap${endColour}"
    sudo snap install node --classic
    echo -e "${yellowColour}Cleaning up and updating package database.${endColour}"
    sudo updatedb
    echo -e "${greenColour}All packages installed successfully.${endColour}"
    sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.zshrc-arch" "/home/$SUDO_USER/.zshrc" 
    sudo ln -s -f "/home/$SUDO_USER/.zshrc" "/root/.zshrc"
    sudo mkdir -p /usr/share/fonts/truetype
}

function core_package(){
    echo -e "${yellowColour}Install tools with curl.${endColour}"
    cd /home/$SUDO_USER/Downloads
    echo -e "${yellowColour}Install themes polybar.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo git clone https://github.com/adi1090x/polybar-themes.git
    cd polybar-themes
    cp "/home/$SUDO_USER/Downloads/Entorno/setup.sh" "/home/$SUDO_USER/Downloads/polybar-themes/setup.sh"
    cd /home/$SUDO_USER/Downloads/polybar-themes
    sudo chmod +x setup.sh
    ./setup.sh
    # in bspwnrc
    #Available Themes : --
    #--blocks    --colorblocks    --cuts      --docky
    #--forest    --grayblocks     --hack      --material
    #--panels    --pwidgets       --shades    --shapes
    #launch4.sh   
}


#BaseInstalation
function enviroment(){
    echo -e "${yellowColour}The Bspwn environment will be installed.${endColour}"
    echo -e "${yellowColour}Install bspwn and sxhkd.${endColour}"
    cd /home/$SUDO_USER/Downloads/
    #CloneRepo
    sudo -u "$SUDO_USER" git clone https://github.com/baskerville/bspwm.git
    sudo -u "$SUDO_USER" git clone https://github.com/baskerville/sxhkd.git
    cd /home/$SUDO_USER/Downloads/bspwm/
    make
    sudo make install
    cd /home/$SUDO_USER/Downloads/sxhkd/
    make
    sudo make install    
    #ConfigurationPolyvar
    echo -e "${yellowColour}Configure polybar fonts.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo -u "$SUDO_USER" git clone https://github.com/VaughnValle/blue-sky.git
    cd /home/$SUDO_USER/Downloads/blue-sky/polybar/
    sudo -u "$SUDO_USER" cp * -r /home/$SUDO_USER/.config/polybar
    cd /home/$SUDO_USER/Downloads/blue-sky/polybar/fonts
    sudo cp * /usr/share/fonts/truetype/
    pushd /usr/share/fonts/truetype &>/dev/null 
    fc-cache -v
    popd &>/dev/null
    echo -e "${yellowColour}Picom compilation.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo -u "$SUDO_USER" git clone https://github.com/ibhagwan/picom.git
    cd picom/
    git submodule update --init --recursive
    meson --buildtype=release . build
    ninja -C build
    sudo ninja -C build install
    #InstallPolybarCompilation
    if [[ -f /etc/os-release ]]; then
        if grep -q "kali" /etc/os-release || grep -q "parrot" /etc/os-release || grep -q "ubuntu" /etc/os-release; then
            echo -e "${yellowColour}Polybar compilation .${endColour}"
            cd /home/$SUDO_USER/Downloads
            sudo -u "$SUDO_USER" git clone --recursive https://github.com/polybar/polybar
            cd polybar/
            mkdir build
            cd build/
            cmake ..
            make -j$(nproc)
            sudo make install
        elif [[ -f /etc/arch-release ]]; then
            echo -e "${yellowColour}Creating swap and compiling Polybar for Arch Linux .${endColour}"
            sleep 5
            sudo fallocate -l 2G /swapfile
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile
            cd /home/$SUDO_USER/Downloads
            echo -e "${redColour}If the polybar doesn't compile, compile it separately and reload it with Alt + r.${endColour}"
            sudo -u "$SUDO_USER" git clone --recursive https://github.com/polybar/polybar
            cd polybar/
            mkdir build
            cd build/
            sleep 5
            cmake .. -DBUILD_DOCS=OFF
            sleep 5
            make -j$(nproc)
            sleep 5
            sudo make install
            sudo swapoff /swapfile
            sudo rm /swapfile
        else
            echo -e "\n${redColour}The system is neither Debian, Ubuntu, nor Arch Linux.${endColour}"
        fi
    else
        echo -e "\n${redColour}The system doesn't have /etc/os-release. Cannot determine the OS.${endColour}"
    fi
        echo -e "${yellowColour}Install themes polybar.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo git clone https://github.com/adi1090x/polybar-themes.git
    cd polybar-themes
    cp "/home/$SUDO_USER/Downloads/Entorno/setup.sh" "/home/$SUDO_USER/Downloads/polybar-themes/setup.sh"
    cd /home/$SUDO_USER/Downloads/polybar-themes
    sudo chmod +x setup.sh
    ./setup.sh
    # in bspwnrc
    #Available Themes : --
    #--blocks    --colorblocks    --cuts      --docky
    #--forest    --grayblocks     --hack      --material
    #--panels    --pwidgets       --shades    --shapes
    #CopyFiles    
    echo -e "${yellowColour}Move files configuration.${endColour}"
    sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/bspwm" "/home/$SUDO_USER/.config/"
    sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/sxhkd" "/home/$SUDO_USER/.config/"
    sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/picom" "/home/$SUDO_USER/.config/"
    sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/kitty" "/home/$SUDO_USER/.config/"
    sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/rofi" "/home/$SUDO_USER/.config/"
    sudo cp "/home/$SUDO_USER/Downloads/Entorno/fastTCPscan.go" "/opt/fastTCPscan"
    sudo chmod 755 /opt/fastTCPscan
    sudo ln -s -f "/opt/fastTCPscan" "/usr/local/bin/fastTCPscan"
    sudo -u "$SUDO_USER" cp -r "/home/$SUDO_USER/Downloads/Entorno/polybar/forest" "/home/$SUDO_USER/.config/polybar/forest"
    sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/polybar/launch.sh" "/home/$SUDO_USER/.config/polybar/launch.sh"
    sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/.p10k.zsh" "/home/$SUDO_USER/.p10k.zsh"
    sudo chmod +x "/home/$SUDO_USER/.config/sxhkd/sxhkdrc"
    sudo chmod +x "/home/$SUDO_USER/.config/bspwm/bspwmrc"
    sudo chmod +x "/home/$SUDO_USER/.config/bspwm/scripts/bspwm_resize"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/launch.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/picom/picom.conf"
    sudo chmod +x "/home/$SUDO_USER/.config/kitty/kitty.conf"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/preview.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/launch.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/scroll_spotify_status.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/get_spotify_status.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/target.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/checkupdates"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/launcher.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/powermenu.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/style-switch.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/styles.sh"
    sudo chmod +x "/home/$SUDO_USER/.config/polybar/forest/scripts/updates.sh"
    sudo mkdir -p /opt/whichSystem
    cp "/home/$SUDO_USER/Downloads/Entorno/whichSystem.py" "/opt/whichSystem/whichSystem.py"
    sudo ln -s -f "/opt/whichSystem/whichSystem.py" "/usr/local/bin/"
    #InstallPower
    echo -e "${yellowColour}Download powerlevel10k.${endColour}"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /home/$SUDO_USER/powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git /root/powerlevel10k
    #InstallFonts
    echo -e "${yellowColour}Install Hack Nerd Fonts.${endColour}"
    cd /home/$SUDO_USER/Downloads 
    sudo wget -q https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/Hack.zip
    sudo unzip Hack.zip > /dev/null 2>&1 && sudo mv *.ttf /usr/local/share/fonts/
    sudo rm Hack.zip LICENSE.md README.md *.ttf
    pushd /usr/local/share/fonts/
    fc-cache -v
    popd
    #InstallWallpaper
    echo -e "${yellowColour}Configuration wallpaper.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo -u "$SUDO_USER" mkdir -p /home/$SUDO_USER/Pictures
    sudo cp -r /home/$SUDO_USER/Downloads/Entorno/3.png /home/$SUDO_USER/Pictures
    echo -e "${yellowColour}Install plugin sudo.${endColour}"
    sudo mkdir /usr/share/zsh-sudo
    sudo wget -q https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/plugins/sudo/sudo.plugin.zsh
    sudo cp sudo.plugin.zsh /usr/share/zsh-sudo/  
    #InstallBatcat
    echo -e "${yellowColour}Install batcat.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo wget -q https://github.com/sharkdp/bat/releases/download/v0.24.0/bat-musl_0.24.0_amd64.deb
    sudo dpkg -i bat-musl_0.24.0_amd64.deb
    #InstallLSD
    echo -e "${yellowColour}Install lsd.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo wget -q https://github.com/lsd-rs/lsd/releases/download/v1.0.0/lsd-musl_1.0.0_amd64.deb
    sudo dpkg -i lsd-musl_1.0.0_amd64.deb
    #Installfzf
    echo -e "${yellowColour}Install fzf.${endColour}"
    sudo -u "$SUDO_USER" git clone --depth 1 https://github.com/junegunn/fzf.git /home/$SUDO_USER/.fzf &>/dev/null
    sudo -u "$SUDO_USER" /home/$SUDO_USER/.fzf/install --all &>/dev/null
    sudo git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf &>/dev/null
    sudo ~/.fzf/install --all &>/dev/null
    #InstallNvchad
    echo -e "${yellowColour}Install nvcahd.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo rm -rf /home/$SUDO_USER/.config/nvim
    sudo wget -q https://github.com/neovim/neovim-releases/releases/download/v0.10.1/nvim-linux64.deb 
    sudo dpkg -i nvim-linux64.deb 
    sudo -u "$SUDO_USER" git clone https://github.com/NvChad/starter /home/$SUDO_USER/.config/nvim && nvim
    sudo rm -rf /root/.config/nvim
    sudo git clone https://github.com/NvChad/starter /root/.config/nvim && nvim
    sudo ln -s -f "/home/$SUDO_USER/.p10k.zsh" "/root/.p10k.zsh"
    sudo usermod --shell /usr/bin/zsh "$SUDO_USER"
    sudo usermod --shell /usr/bin/zsh root
    sudo chown "$SUDO_USER:$SUDO_USER" "/root"
    sudo chown "$SUDO_USER:$SUDO_USER" "/root/.cache" -R
    sudo chown "$SUDO_USER:$SUDO_USER" "/root/.local" -R
}

#reporting tools
function latex(){
    cd /home/$SUDO_USER/Downloads
    wget -q https://github.com/obsidianmd/obsidian-releases/releases/download/v1.5.8/obsidian_1.5.8_amd64.deb
    sudo dpkg -i obsidian_1.5.8_amd64.deb
    if [[ -f /etc/debian_version || ( -f /etc/os-release && "$ID" == "ubuntu" ) ]]; then
        echo -e "${yellowColour}The latex environment will be installed, this will take more than 30 minutes approximately..${endColour}"
        apt install latexmk zathura rubber texlive-full -y --fix-missing
    elif [ -f /etc/arch-release ]; then
        echo -e "${yellowColour}The latex environment will be installed, this will take more than 30 minutes approximately..${endColour}"
        sudo pacman -S --needed --noconfirm texlive-most zathura zathura-pdf-poppler
    else
        echo "El sistema no es ni Debian, ni Arch Linux, ni Ubuntu"
    fi
}

function repositonies(){
    sudo git clone https://github.com/epinna/weevely3 /opt/weevely3
}

function spotify(){
    cd /home/$SUDO_USER/Downloads
    git clone https://github.com/noctuid/zscroll
    cd zscroll
    sudo python3 setup.py install
    sudo rm "/home/$SUDO_USER/.config/polybar/forest/user_modules.ini"
    sudo -u "$SUDO_USER" cp "/home/$SUDO_USER/Downloads/Entorno/polybar/forest/user_modules-copia.ini" "/home/$SUDO_USER/.config/polybar/forest/user_modules.ini"
    if [[ -f /etc/os-release ]]; then
        if grep -q "kali" /etc/os-release || grep -q "parrot" /etc/os-release || grep -q "ubuntu" /etc/os-release; then
            echo -e "${greenColour}Install spotify.${endColour}"
            sudo apt install playerctl -y
            curl -sS https://download.spotify.com/debian/pubkey_6224F9941A8AA6D1.gpg | sudo gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
            echo "deb http://repository.spotify.com stable non-free" | sudo tee /etc/apt/sources.list.d/spotify.list
            sudo apt-get install spotify-client -y
        elif grep -q "arch" /etc/os-release; then
            echo -e "${greenColour}Install spotify.${endColour}"
            sudo pacman -S playerctl --noconfirm
            sudo snap install spotify
            sudo systemctl --user enable --now mpd.service
            sudo systemctl is-enabled --quiet mpd.service

        else
            echo -e "\n${redColour}The system is neither Debian, Ubuntu, nor Arch Linux.${endColour}"
            exit 1
        fi
    else
        echo -e "\n${redColour}The system doesn't have /etc/os-release. Cannot determine the OS.${endColour}"
        exit 1
    fi
}

function clean() {
    echo -ne "\n\t${purpleColour}We are cleaning everything.${endColour}"
    sudo rm -rf /home/$SUDO_USER/Downloads/*
    sudo find . -type d -name "Entorno"  -exec rm -r {} \;
    if [[ -f /etc/os-release ]]; then
        if grep -q "kali" /etc/os-release || grep -q "parrot" /etc/os-release || grep -q "ubuntu" /etc/os-release; then
            sudo apt --fix-broken install -y
            sudo apt update -y
            sudo apt dist-upgrade -y
            sudo apt autoremove -y
        elif [[ -f /etc/arch-release ]]; then
            sudo pacman -Scc --noconfirm
            sudo pacman -Syu --noconfirm
            sudo pacman -Qk --noconfirm
            sudo pacman -Rns $(pacman -Qdtq) --noconfirm
            echo -ne "\n\t${purpleColour}Habilitando demonios.${endColour}"
            localectl set-x11-keymap es
            sudo chown root:root /usr/local/share/zsh/site-functions/_bspc
            sudo systemctl enable vmtoolsd
            sudo systemctl enable gdm.service
            sudo systemctl start gdm.service
        else
            echo -e "\n${redColour}The system is neither Debian, Ubuntu, nor Arch Linux.${endColour}"
        fi
    else
        echo -e "\n${redColour}The system doesn't have /etc/os-release. Cannot determine the OS.${endColour}"
    fi
}

function session(){
    echo -ne "\n\t${redColour} We are closing the session to apply the new configuration, be sure to select the BSPWN.${endColour}" 
    sleep 10
    kill -9 -1
}

function helpPanel() {
    echo -e "\n${greenColour}[!] Uso: sudo $0 -d {Mode} [-r] [-l] [-s]${endColour}"
    echo -e "\t${blueColour}[-d] Mode of installation.${endColour}"
    echo -e "\t\t${turquoiseColour}debian${endColour}\t\t\t${yellowColour}Distribution Debian/Ubuntu nesesary =< 60 gb.${endColour}"
    echo -e "\t\t${purpleColour}archlinux${endColour}\t\t${yellowColour}Distribution Archlinux nesesary       =< 60 gb.${endColour}"
    echo -e "\t${yellowColour}Opcionales:${endColour}"
    echo -e "\t\t${yellowColour}-r${endColour}\t\t\t${greenColour}Tools Repositories (Tools for OSCP) nesesary =< 160 gb.${endColour}"
    echo -e "\t\t${yellowColour}-l${endColour}\t\t\t${greenColour}LaTeX Environment (It tackes 30 min more)${endColour}"
    echo -e "\t\t${yellowColour}-s${endColour}\t\t\t${greenColour}Spotify (Only Recomended for more than 16 gb of RAM, the demon use 1 gb of RAM)${endColour}"
    echo -e "\t${redColour}[-h] Show this help panel.${endColour}"
    echo -e "\n${greenColour}Example:${endColour}"
    echo -e "\t${blueColour}sudo $0 -d debian-ubuntu -r -l${endColour}\t${yellowColour}(Install enviroment with repositonies and latex and spotify)${endColour}"
    tput cnorm; exit 1
}

declare -i parameter_counter=0
repositories=false
latex=false
spotify=false

while getopts ":d:rlsh" arg; do
    case $arg in
        d) Mode=$OPTARG; let parameter_counter+=1 ;;
        r) repositories=true ;;
        l) latex=true ;;
        s) spotify=true ;;
        h) helpPanel ;;
        *) echo -e "${redColour}[!] Invalid option.${endColour}"; helpPanel ;;
    esac
done

tput civis

shift $((OPTIND - 1))

# Verificar si hay argumentos adicionales no permitidos
if [ $# -ne 0 ]; then
    echo -e "${redColour}[!] Invalid arguments: $*${endColour}"
    helpPanel
fi

# Validar el valor de -d
if [[ "$Mode" != "debian" && "$Mode" != "archlinux" ]]; then
    echo -e "${redColour}[!] Invalid mode: $Mode${endColour}"
    helpPanel
fi

# Validar si hay al menos un parámetro obligatorio
if [ $parameter_counter -eq 0 ]; then
    helpPanel
fi

# Ejecutar según el modo seleccionado
if [ "$Mode" == "debian" ]; then
    check
    check_os
    core_package
    enviroment
    if [ "$repositories" == true ]; then
        repositories
    fi
    if [ "$latex" == true ]; then
        latex
    fi
    if [ "$spotify" == true ]; then
        spotify
    fi
    clean
    session
elif [ "$Mode" == "archlinux" ]; then
    check
    check_os
    core_package
    enviroment
    if [ "$repositories" == true ]; then
        repositories
    fi
    if [ "$latex" == true ]; then
        latex
    fi
    if [ "$spotify" == true ]; then
        spotify
    fi
    clean
    session
else
    echo -e "${redColour}[!] Invalid mode.${endColour}"
    helpPanel
    tput cnorm
    exit 1
fi

tput cnorm
exit 0


