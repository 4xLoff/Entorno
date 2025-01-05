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
    echo -e "${yellowColour}Install rustscan.${endColour}"
    cd /home/$SUDO_USER/Downloads
    sudo curl -sL https://github.com/RustScan/RustScan/releases/download/2.2.3/rustscan_2.2.3_amd64.deb -o rustscan_2.2.3_amd64.deb 
    sudo dpkg -i rustscan_2.2.3_amd64.deb
    cd /home/$SUDO_USER/Downloads
    echo -e "${yellowColour}Install ferxo.${endColour}"
    sudo curl -sL https://github.com/epi052/feroxbuster/releases/download/v2.11.0/feroxbuster_amd64.deb.zip -o feroxbuster_amd64.deb.zip
    sudo 7z x feroxbuster_amd64.deb.zip
    sudo dpkg -i feroxbuster_2.11.0-1_amd64.deb
    echo -e "${yellowColour}Adding Microsoft repository.${endColour}"
    sudo wget https://packages.microsoft.com/config/debian/12/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
    sudo dpkg -i packages-microsoft-prod.deb
    sudo rm packages-microsoft-prod.deb
    # Verificar si es Kali Linux y configurar wine
    if [[ -f /etc/os-release && $(grep -q "kali" /etc/os-release; echo $?) -eq 0 ]]; then
        echo -e "${yellowColour}Configuring wine for Kali Linux.${endColour}"
        sudo dpkg --add-architecture i386
    fi
    packages=(
        acl adb antiword apktool aptitude
        apt-transport-https autoconf awscli 
        bc bd binwalk bloodhound bruteforce-luks 
        bspwm build-essential bzip2-doc cadaver 
        caja cargo cewl cifs-utils claws-mail 
        cloud-enum cmake cmake-data crackmapexec 
        crunch cutycapt davtest dbeaver derby-tools 
        default-mysql-client dex2jar dh-autoreconf 
        djvulibre-bin dnsrecon docker.io 
        dotnet-sdk-3.1 dotnet-sdk-6.0 dotnet-sdk-8.0 
        encfs enum4linux enum4linux-ng evince 
        evolution exiftool exploitdb extundelete 
        feh ffuf flameshot flite fontconfig 
        freerdp2-dev freerdp2-x11 fuse fusermount 
        gcc-multilib gdb gimp gitleaks glusterfs-server 
        gnupg gospider gpp-decrypt gss-ntlmssp 
        hash-identifier hexchat hexedit html2text 
        hurl imagemagick impacket-scripts 
        inetutils-ftp irssi jadx jd-gui jq kcat 
        keepassxc kitty knockd kpcli krb5-user 
        lftp libasound2-dev libbsd-dev libbz2-dev
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
        mdbtools meson mingw-w64-tools mongodb-org mongo-tools 
        mono-devel mutt ncat neo4j netexec nmap nodejs npm 
        odat pacu padbuster pdfid pdf-parser peass pgcli 
        php-curl phpggc pidgin pipx pkg-config pngcrush polybar 
        powercat powershell powershell-empire powersploit 
        protobuf-compiler pst-utils putty-tools python3 python3-dev 
        python3-impacket python3-ldap python3-ldapdomaindump 
        python3-pip python3-sphinx python3-xcbgen qrencode radare2 
        rails ranger rdesktop recordmydesktop redis-tools remina 
        remina-plugin-spice rlwrap rofi ruby ruby-dev samba 
        scrot seclists sendemail sendmail shellter skipfish 
        smbmap snap snapd snmp snmp-mibs-downloader 
        software-properties-common sprayingtoolkit squidclient 
        steghide sublist3r subversion suckless-tools sucrack 
        swaks tcpdump tesseract-ocr tigervnc-viewer tnscmd10g 
        translate-shell uthash-dev veil vim wayland-protocols 
        wbasic whatweb wkhtmltopdf wmis xcb-proto xclip xpdf 
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
        acl adb antiword autoconf 
        bat bc binwalk bloodhound brightnessctl 
        bruteforce-luks bspwm caja cargo 
        chromium cifs-utils claws-mail cmake 
        crunch cutycapt davtest dbeaver 
        dex2jar djvulibre dmenu dnsrecon 
        docker docker-compose dotnet-sdk 
        dpkg dtnet-sdk dunst emacs enum4linux 
        evolution eww-git exploitdb eza feh 
        ferxobuster firefox flameshot flite 
        fontconfig freerdp gcc-multilib gdb 
        geany gimp gnupg go gospider gtkmm 
        gvfs-mtp hash-identifier hexchat 
        html2text htop hurl i3lock-color 
        imagemagick impacket inetutils irssi 
        jadx jgmenu jq keepassxc kitty krb5 
        lftp libcanberra-gtk-module libconfig 
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
        padbuster pamixer papirus-icon-theme 
        pdfid pdf-parser peass phpggc picom 
        pidgin pipx pkg-config playerctl 
        pngcrush polkit-gnome polybar python 
        python-gobject python-ldap python-pip
        python-pipx python-sphinx radare2 
        ranger rdesktop recordmydesktop redshift 
        remmina rlwrap rmdbtools rofi rofi-greenclip 
        ruby rustup samba scrot seclists 
        wine shellter simple-mtpfs skipfish 
        smbmap sprayingtoolkit sqlite3 steghide 
        sublist3r subversion sucrack sudo swaks 
        sxhkd tcpdump tdrop-git tigervnc 
        translate-shell ttf-maple ueberzug 
        uthash veil wafw00f wayland-protocols 
        webp-pixbuf-loader whatweb wkhtmltopdf
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
    #Install vsc
    echo -e "${yellowColour}Install VSC.${endColour}"
    sudo curl -s "https://vscode.download.prss.microsoft.com/dbazure/download/stable/d78a74bcdfad14d5d3b1b782f87255d802b57511/code_1.94.0-1727878498_amd64.deb" -o code_1.94.0-1727878498_amd64.deb
    sudo dpkg -i --force-confnew code_1.94.0-1727878498_amd64.deb
    #Install pipx Packeage
    echo -e "${yellowColour}Install python tools with pipx.${endColour}" 
    python3 -m pip install --user pipx --break-system-packages
    sudo pipx install impacket 
    sudo pipx install setuptools
    sudo pipx install donpapi
    sudo pipx install git+https://github.com/blacklanternsecurity/MANSPIDER 
    #Install pip3 Packeage
    echo -e "${yellowColour}Install python tools with pip3.${endColour}"
    sudo -H pip3 install -U https://github.com/decalage2/oletools/archive/master.zip --break-system-packages
    sudo -H pip3 install -U https://github.com/decalage2/ViperMonkey/archive/master.zip --break-system-packages
    sudo -H pip3 install git+https://github.com/ly4k/ldap3 --break-system-packages
    sudo -H pip3 install --upgrade paramiko cryptography pyOpenSSL scapy awscli botocore urllib3 --break-system-packages
    sudo -H pip3 install --user pysmb --break-system-packages
    sudo -H pip3 install cheroot wsgidav gitpython impacket minikerbero ezodf pyreadline3 oathtool oletools pwncat-cs pwntools updog wsgidav pypykatz python-ldap html2markdown scapy colored oletools droopescan uncompyle6 web3 acefile bs4 pyinstaller flask-unsign uncompyle6 pyDes fake_useragent alive_progress githack bopscrk pwncat-cs hostapd-mana git-dumper six crawley certipy-ad pypykatz chepy minidump minikerberos aiowinreg msldap winacl ezodf pymemcache --break-system-packages
    #Install pip2 Packeage
    echo -e "${yellowColour}Install python2 tools.${endColour}"
    cd /tmp
    sudo curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip.py
    sudo python2 get-pip.py
    sudo pip2 install requests urllib3 beautifulsoup4 lxml paramiko pillow pycrypto scapy dnspython pexpect simplejson pyyaml ezodf 
    echo -e "${yellowColour}Install gef tools.${endColour}"
    #installgef
    bash -c "$(curl -fsSL https://gef.blah.cat/sh)"
    echo -e "${yellowColour}Install snap tools.${endColour}"
    sudo snap install ngrok storage-explorer
    sudo snap install snapcraft kubectl --classic
    echo -e "${yellowColour}Install npm tools.${endColour}"
    #Install gem Packeage
    sudo gem install evil-winrm http httpx docopt rest-client colored2 wpscan winrm-fs stringio logger fileutils winrm brakeman
    echo -e "${yellowColour}Install python3 tools.${endColour}"
    sudo python3 -m pipx install impacket git-dumper --break-system-packages
    sudo python3 -m pip install --upgrade pwntools --break-system-packages
    #Install go Packeage
    echo -e "${yellowColour}Install go tools.${endColour}"
    cd /home/$SUDO_USER/Downloads
    wget https://go.dev/dl/go1.21.4.linux-amd64.tar.gz
    sudo tar -C /usr/local/ -xzf go1.21.4.linux-amd64.tar.gz 
    sudo go install github.com/benbusby/namebuster@latest
    sudo go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
    echo -e "${yellowColour}Install npm tools.${endColour}"
    sudo npm install -g safe-backup wscat asar memcached-cli node-serialize slendr electron-packager
    cd /home/$SUDO_USER/Downloads
    git clone https://github.com/qtc-de/remote-method-guesser
    cd remote-method-guesser
    mvn package
    cd /home/$SUDO_USER/Downloads
    git clone https://github.com/CravateRouge/bloodyAD.git
    cd bloodyAD
    pip3 install . --break-system-packages
    cd /opt
    git clone https://github.com/wirzka/incursore.git
    cd incursore
    sudo ln -s $(pwd)/incursore/incursore.sh /usr/local/bin/
    echo -e "${yellowColour}Install docker.${endolour}"
    cd /home/$SUDO_USER/Downloads
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
    sudo usermod -aG docker $SUDO_USER
    cd /home/$SUDO_USER/Downloads
    sleep 1
    echo -e "${yellowColour}Install AvaloniaILSp.${endolour}"
    mkdir /opt/AvaloniaILSpy
    cd /opt/AvaloniaILSpy
    wget -q https://github.com/icsharpcode/AvaloniaILSpy/releases/download/v7.2-rc/Linux.x64.Release.zip
    mv /home/$SUDO_USER/Downloads/Linux.x64.Release.zip .
    unzip Linux.x64.Release.zip
    rm Linux.x64.Release.zip
    unzip ILSpy-linux-x64-Release.zip
    rm ILSpy-linux-x64-Release.zip
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
    sudo git clone https://github.com/epinna/tplmap.git /opt/tplmap
    sudo git clone https://github.com/HarmJ0y/pylnker /opt/pylnker
    sudo git clone https://github.com/3mrgnc3/BigheadWebSvr.git /opt/BigheadWebSvr
    sudo git clone https://github.com/IOActive/jdwp-shellifier.git /opt/jdwp-shellifier
    sudo git clone https://github.com/danielbohannon/Invoke-Obfuscation.git /opt/Invoke-Obfuscation
    sudo git clone https://github.com/manulqwerty/Evil-WinRAR-Gen.git /opt/Evil-WinRAR-Gen
    sudo git clone https://github.com/ptoomey3/evilarc.git /opt/evilarc
    sudo git clone https://github.com/NotSoSecure/docker_fetch /opt/docker_fetch
    sudo git clone https://github.com/cnotin/SplunkWhisperer2.git /opt/SplunkWhisperer2
    sudo git clone https://github.com/kozmic/laravel-poc-CVE-2018-15133 /opt/laravel-poc-CVE-2018-15133
    sudo git clone https://github.com/ambionics/phpggc.git /opt/phpggc
    sudo git clone https://github.com/kozmer/log4j-shell-poc.git /opt/log4j-shell-poc
    sudo git clone https://github.com/epinna/weevely3.git /opt/weevely3
    sudo git clone https://github.com/ohoph/3bowla.git /opt/3bowla
    sudo git clone https://github.com/v1s1t0r1sh3r3/airgeddon.git /opt/airgeddon
    sudo git clone https://github.com/anbox/anbox.git /opt/anbox
    sudo git clone https://github.com/anbox/anbox-modules.git /opt/anbox-modules
    sudo git clone https://github.com/securecurebt5/BasicAuth-Brute.git /opt/BasicAuth-Brute
    sudo git clone https://github.com/mazen160/bfac.git /opt/bfac
    sudo git clone https://github.com/kimci86/bkcrack.git /opt/bkcrack
    sudo git clone https://github.com/micro-joan/BlackStone.git /opt/BlackStone
    sudo git clone https://github.com/SpecterOps/BloodHound.git /opt/BloodHound
    sudo git clone https://github.com/r3nt0n/bopscrk.git /opt/bopscrk
    sudo git clone https://github.com/presidentbeef/brakeman.git /opt/brakeman
    sudo git clone https://github.com/glv2/bruteforce-luks.git /opt/bruteforce-luks
    sudo git clone https://github.com/lobuhi/byp4xx.git /opt/byp4xx
    sudo git clone https://github.com/ly4k/Certipy.git /opt/Certipy
    sudo git clone https://github.com/theevilbit/ciscot7.git /opt/ciscot7
    sudo git clone https://github.com/pentester-io/commonspeak.git /opt/commonspeak
    sudo git clone https://github.com/qtc-de/completion-helpers /opt/completion-helpers
    sudo git clone https://github.com/crackpkcs12/crackpkcs12.git /opt/crackpkcs12
    sudo git clone https://github.com/jmg/crawley /opt/crawley
    sudo git clone https://github.com/Tib3rius/creddump7.git /opt/creddump7
    sudo git clone https://github.com/UnaPibaGeek/ctfr.git /opt/ctfr
    sudo git clone https://github.com/Mebus/cupp.git /opt/cupp
    sudo git clone https://github.com/curl/curl /opt/curl
    sudo git clone https://github.com/sm00v/Dehashed.git /opt/Dehashed
    sudo git clone https://github.com/spipm/Depix /opt/Depix
    sudo git clone https://github.com/teambi0s/dfunc-bypasser /opt/dfunc-bypasser
    sudo git clone https://github.com/iagox86/dnscat2.git /opt/dnscat2
    sudo git clone https://github.com/lukebaggett/dnscat2-powershell.git /opt/dnscat2-powershell
    sudo git clone https://github.com/dnSpy/dnSpy.git /opt/dnSpy
    sudo git clone https://github.com/Syzik/DockerRegistryGrabber.git /opt/DockerRegistryGrabber
    sudo git clone https://github.com/baztian/docker-wine.git /opt/docker-wine
    sudo git clone https://github.com/s0lst1c3/eaphammer.git /opt/eaphammer
    sudo git clone https://github.com/Genetic-Malware/Ebowla.git /opt/Ebowla
    sudo git clone https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng
    sudo git clone https://github.com/trickster0/Enyx /opt/Enyx
    sudo git clone https://github.com/shivsahni/FireBaseScanner /opt/FireBaseScanner
    sudo git clone https://github.com/unode/firefox_decrypt.git /opt/firefox_decrypt
    sudo git clone https://github.com/lclevy/firepwd.git /opt/firepwd
    sudo git clone https://github.com/yonjar/fixgz.git /opt/fixgz
    sudo git clone https://github.com/Sn1r/Forbidden-Buster.git /opt/Forbidden-Buster
    sudo git clone https://github.com/gotr00t0day/forbiddenpass.git /opt/forbiddenpass
    sudo git clone https://github.com/carlospolop/fuzzhttpbypass.git /opt/fuzzhttpbypass
    sudo git clone https://github.com/zackelia/ghidra-dark.git /opt/ghidra-dark
    sudo git clone https://github.com/git-cola/git-cola.git /opt/git-cola
    sudo git clone https://github.com/arthaud/git-dumper.git /opt/git-dumper
    sudo git clone https://github.com/lijiejie/GitHack.git /opt/GitHack
    sudo git clone https://github.com/internetwache/GitTools.git /opt/GitTools
    sudo git clone https://github.com/micahvandeusen/gMSADumper.git /opt/gMSADumper
    sudo git clone https://github.com/tarunkant/Gopherus.git /opt/Gopherus
    sudo git clone https://github.com/ropnop/go-windapsearch.git /opt/go-windapsearch
    sudo git clone https://github.com/ZerBea/hcxdumptool.git /opt/hcxdumptool
    sudo git clone https://github.com/ZerBea/hcxtools.git /opt/hcxtools
    sudo git clone https://github.com/GitMirar/hMailDatabasePasswordDecrypter.git /opt/hMailDatabasePasswordDecrypter
    sudo git clone https://github.com/sensepost/hostapd-mana /opt/hostapd-mana
    sudo git clone https://github.com/ropnop/kerbrute.git /opt/kerbrute
    sudo git clone https://github.com/yasserjanah/HTTPAuthCracker.git /opt/HTTPAuthCracker
    sudo git clone https://github.com/LorenzoTullini/InfluxDB-Exploit-CVE-2019-20933.git /opt/InfluxDB-Exploit-CVE-2019-20933
    sudo git clone https://github.com/AresS31/jwtcat /opt/jwtcat
    sudo git clone https://github.com/ticarpi/jwt_tool /opt/jwt_tool
    sudo git clone https://github.com/attackdebris/kerberos_enum_userlists.git /opt/kerberos_enum_userlists
    sudo git clone https://github.com/chris408/known_hosts-hashcat /opt/known_hosts-hashcat
    sudo git clone https://github.com/dirkjanm/krbrelayx.git /opt/krbrelayx
    sudo git clone https://github.com/libyal/libesedb.git /opt/libesedb
    sudo git clone https://github.com/nicocha30/ligolo-ng.git /opt/ligolo-ng
    sudo git clone https://github.com/initstring/linkedin2username /opt/linkedin2username
    sudo git clone https://github.com/Plazmaz/LNKUp.git /opt/LNKUp
    sudo git clone https://github.com/wetw0rk/malicious-wordpress-plugin.git /opt/malicious-wordpress-plugin
    sudo git clone https://github.com/haseebT/mRemoteNG-Decrypt.git /opt/mRemoteNG-Decrypt
    sudo git clone https://github.com/NotMedic/NetNTLMtoSilverTicket.git /opt/NetNTLMtoSilverTicket
    sudo git clone https://github.com/ernw/nmap-parse-output /opt/nmap-parse-output
    sudo git clone https://github.com/akinerk/NoMoreForbidden.git /opt/NoMoreForbidden
    sudo git clone https://github.com/Ridter/noPac.git /opt/noPac
    sudo git clone https://github.com/m8sec/nullinux /opt/nullinux
    sudo git clone https://github.com/quentinhardy/odat /opt/odat
    sudo git clone https://github.com/decalage2/oletools.git /opt/oletools
    sudo git clone https://github.com/Daniel10Barredo/OSCP_AuxReconTools.git /opt/OSCP_AuxReconTools
    sudo git clone https://github.com/flozz/p0wny-shell.git /opt/p0wny-shell
    sudo git clone https://github.com/mpgn/Padding-oracle-attack.git /opt/Padding-oracle-attack
    sudo git clone https://github.com/AlmondOffSec/PassTheCert.git /opt/PassTheCert
    sudo git clone https://github.com/brightio/penelope.git /opt/penelope
    sudo git clone https://github.com/topotam/PetitPotam.git /opt/PetitPotam
    sudo git clone https://github.com/scr34m/php-malware-scanner.git /opt/php-malware-scanner
    sudo git clone https://github.com/dirkjanm/PKINITtools.git /opt/PKINITtools
    sudo git clone https://github.com/aniqfakhrul/powerview.py /opt/powerview.py
    sudo git clone https://github.com/byt3bl33d3r/pth-toolkit.git /opt/pth-toolkit
    sudo git clone https://github.com/utoni/ptunnel-ng.git /opt/ptunnel-ng
    sudo git clone https://github.com/calebstewart/pwncat.git /opt/pwncat
    sudo git clone https://github.com/Gallopsled/pwntools /opt/pwntools
    sudo git clone https://github.com/LucifielHack/pyinstxtractor.git /opt/pyinstxtractor
    sudo git clone https://github.com/3gstudent/pyKerbrute.git /opt/pyKerbrute
    sudo git clone https://github.com/p0dalirius/pyLAPS.git /opt/pyLAPS
    sudo git clone https://github.com/JPaulMora/Pyrit.git /opt/Pyrit
    sudo git clone https://github.com/WithSecureLabs/python-exe-unpacker.git /opt/python-exe-unpacker
    sudo git clone https://github.com/ShutdownRepo/pywhisker.git /opt/pywhisker
    sudo git clone https://github.com/cloudflare/quiche /opt/quiche
    sudo git clone https://github.com/radareorg/radare2 /opt/radare2
    sudo git clone https://github.com/codingo/Reconnoitre.git /opt/Reconnoitre
    sudo git clone https://github.com/n0b0dyCN/RedisModules-ExecuteCommand.git /opt/RedisModules-ExecuteCommand
    sudo git clone https://github.com/Ridter/redis-rce.git /opt/redis-rce
    sudo git clone https://github.com/n0b0dyCN/redis-rogue-server.git /opt/redis-rogue-server
    sudo git clone https://github.com/allyshka/Rogue-MySql-Server.git /opt/Rogue-MySql-Server
    sudo git clone https://github.com/sensepost/reGeorg /opt/reGeorg
    sudo git clone https://github.com/klsecservices/rpivot.git /opt/rpivot
    sudo git clone https://github.com/silentsignal/rsa_sign2n.git /opt/rsa_sign2n
    sudo git clone https://github.com/SolomonSklash/RubeusToCcache.git /opt/RubeusToCcache
    sudo git clone https://github.com/Flangvik/SharpCollection.git /opt/SharpCollection
    sudo git clone https://github.com/Pepelux/sippts.git /opt/sippts
    sudo git clone https://github.com/SafeBreach-Labs/SirepRAT /opt/SirepRAT
    sudo git clone https://github.com/SECFORCE/SNMP-Brute.git /opt/SNMP-Brute
    sudo git clone https://github.com/nccgroup/SocksOverRDP.git /opt/SocksOverRDP
    sudo git clone https://github.com/aancw/spose.git /opt/spose
    sudo git clone https://github.com/byt3bl33d3r/SprayingToolkit /opt/SprayingToolkit
    sudo git clone https://github.com/hemp3l/sucrack.git /opt/sucrack
    sudo git clone https://github.com/ShutdownRepo/targetedKerberoast.git /opt/targetedKerberoast
    sudo git clone https://github.com/m3n0sd0n4ld/uDork /opt/uDork
    sudo git clone https://github.com/urbanadventurer/username-anarchy.git /opt/username-anarchy
    sudo git clone https://github.com/Veil-Framework/Veil.git /opt/Veil
    sudo git clone https://github.com/decalage2/ViperMonkey.git /opt/ViperMonkey
    sudo git clone https://github.com/mkubecek/vmware-host-modules.git /opt/vmware-host-modules
    sudo git clone https://github.com/WebAssembly/wabt /opt/wabt
    sudo git clone https://github.com/blunderbuss-wctf/wacker.git /opt/wacker
    sudo git clone https://github.com/Hackndo/WebclientServiceScanner /opt/WebclientServiceScanner
    sudo git clone https://github.com/tennc/webshell /opt/webshell
    sudo git clone https://github.com/bitsadmin/wesng.git /opt/wesng
    sudo git clone https://github.com/ekultek/whatwaf.git /opt/whatwaf
    sudo git clone https://github.com/r4ulcl/wifi_db /opt/wifi_db
    sudo git clone https://github.com/wifiphisher/wifiphisher.git /opt/wifiphisher
    sudo git clone https://github.com/derv82/wifite2.git /opt/wifite2
    sudo git clone https://github.com/ropnop/windapsearch.git /opt/windapsearch
    sudo git clone https://github.com/AonCyberLabs/Windows-Exploit-Suggester.git /opt/Windows-Exploit-Suggester
    sudo git clone https://github.com/mansoorr123/wp-file-manager-CVE-2020-25213.git /opt/wp-file-manager-CVE-2020-25213
    sudo git clone https://github.com/andripwn/WPSeku.git /opt/WPSeku
    sudo git clone https://github.com/artsploit/yaml-payload.git /opt/yaml-payload
    sudo git clone https://github.com/hoto/jenkins-credentials-decryptor.git /opt/jenkins-credentials-decryptor
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


