#!/bin/bash

C=$(printf '\033')
RED="${C}[1;31m"
BLUE="${C}[1;34m"
GREEN="${C}[1;32m"
NC="${C}[0m"

# must run as root man...
if [[ $EUID -ne 0 ]]; then
   echo "${RED}This script must be run as root${NC}" 1>&2
   exit 1
fi

# Fix dual monitor
echo "${GREEN}Fixing dual monitors....${NC}"
git clone https://github.com/Aviksaikat/Hybrid-Graphics-Setup.git /tmp/Hybrid-Graphics-Setup
cd /tmp/Hybrid-Graphics-Setup
chmod +x chmod +x config.sh
sudo ./config.sh


echo "${BLUE}Now Installing all the packages & dependencies buckele up........${NC}"

# Now install the tools
sudo apt update && sudo apt upgrade -y
sudo apt install -y terminator kitty lolcat snapd neofetch fish cargo golang-go obs-studio code-oss
sudo systemctl enable --now snapd apparmor
sudo apt install -y nvidia-driver nvidia-cuda-toolkit
# life saver
sudo apt-get install -y timeshift


# Bluetooth fix
sudo systemctl enable bluetooth.service
sudo service bluetooth start

function install_docker(){

    # update the repos
    sudo apt-get update

    # install docker
    sudo apt install -y docker.io

    # Create the docker group
    sudo groupadd docker

    # Add your user to the docker group
    sudo usermod -aG docker $USER

    # logout & again login as the user
    su - ${USER}
    exit

}

install_docker

function py_3.8() {

    if ! command -v lolcat &> /dev/null
    then
        echo "Lolcat not found installing for fun ;)"
        sudo apt install lolcat || pacman -S lolcat
    fi

    #? if already installed don't bother
    if command -v python3.8 &> /dev/null
    then
        echo "python3.8 already installed :-)" | lolcat
        exit
    fi

    #? checking permissions
    if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root" | lolcat 1>&2
    exit 1
    fi

    echo "Installing Python 3.8 with pip3.8 ...Please wait" | lolcat

    if [ ! -f Python-3.8.0.tar.xz ];
    then
        $(which wget) https://www.python.org/ftp/python/3.8.0/Python-3.8.0.tar.xz
    fi

    if ! command -v tar &> /dev/null
    then
        sudo apt install tar || pacman -S tar
    fi

    $(which tar) -xvf $(pwd)/Python-3.8.0.tar.xz

    #? doing the magic here
    cd Python-3.8.0
    ./configure --enable-optimizations
    sudo make altinstall

    cd ../
    sudo rm -r Python-3.8.0  Python-3.8.0.tar.xz
    echo "Here is the path" | lolcat  &> /dev/null
    echo "$(which python3.8)"

}

py_3.8

function pip2_ins()
{
    sudo apt install python2.7

    if [[ -f "get-pip.py" ]];
        then
            sudo rm get-pip.py
    fi

    wget https://bootstrap.pypa.io/pip/2.7/get-pip.py

    sudo python2.7 get-pip.py

    echo "[*] Checking pip2 version" | lolcat  &> /dev/null

    which pip2.7

    echo "[*] Done..." | lolcat  &> /dev/null

}

pip2_ins

function get_subl() {
    cd ~
    # Sublime text installer for debian(Official Repo)

    # Install the GPG key
    wget -qO - https://download.sublimetext.com/sublimehq-pub.gpg | sudo apt-key add -

    # Ensure apt is set up to work with https sources
    sudo apt-get install apt-transport-https -y

    # Select the channel to use(Stable)
    echo "deb https://download.sublimetext.com/ apt/stable/" | sudo tee /etc/apt/sources.list.d/sublime-text.list

    # Update apt sources and install Sublime Text

    sudo apt-get update -y
    sudo apt-get install -y sublime-text
}

get_subl


function get_brave() {
    # Brave main
    # sudo apt install apt-transport-https curl

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-release.list


    # Brave Beta
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-beta-archive-keyring.gpg https://brave-browser-apt-beta.s3.brave.com/brave-browser-beta-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/brave-browser-beta-archive-keyring.gpg arch=amd64] https://brave-browser-apt-beta.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-beta.list


    # Brave Nightly

    sudo curl -fsSLo /usr/share/keyrings/brave-browser-nightly-archive-keyring.gpg https://brave-browser-apt-nightly.s3.brave.com/brave-browser-nightly-archive-keyring.gpg

    echo "deb [signed-by=/usr/share/keyrings/brave-browser-nightly-archive-keyring.gpg arch=amd64] https://brave-browser-apt-nightly.s3.brave.com/ stable main"|sudo tee /etc/apt/sources.list.d/brave-browser-nightly.list

    sudo apt update

    sudo apt install -y brave-browser brave-browser-beta brave-browser-nightly

}
get_brave

# get obsidian, codium & discord

# get current user & go to his/her downloads dir
USERR=$(last | cut -d ' ' -f1 | head -1)
cd "/home/${USERR}/Downloads"

wget https://github.com/obsidianmd/obsidian-releases/releases/download/v0.15.9/obsidian_0.15.9_amd64.deb
wget https://github.com/VSCodium/vscodium/releases/download/1.70.2.22230/codium_1.70.2.22230_amd64.deb
wget "https://discord.com/api/download?platform=linux&format=deb" -O discord.deb
wget https://github.com/Ulauncher/Ulauncher/releases/download/5.14.7/ulauncher_5.14.7_all.deb
wget https://github.com/Peltoche/lsd/releases/download/0.22.0/lsd-musl_0.22.0_amd64.deb
wget https://github.com/sharkdp/bat/releases/download/v0.21.0/bat-musl_0.21.0_amd64.deb
sudo dpkg -i *.deb

# there will be errors while installing
sudo apt install -f -y
sudo dpkg -i *.deb

#snap packages
sudo snap install core
sudo snap install slack
sudo snap install spotify
sudo snap install libreoffice
sudo snap install chromium
sudo snap install code --classic
sudo snap install code-insiders --classic
sudo snap install signal-desktop
sudo snap install telegram-desktop
sudo snap install kdenlive
sudo snap install notion-snap
sudo snap install gimp



# Oh my zsh.. add them in the config file later
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting


git clone https://github.com/garabik/grc.git /tmp/grc
cd /tmp/grc
chmod +x install.sh
sudo ./install.sh

# rxfecth
git clone https://github.com/mangeshrex/rxfetch /tmp/rxfetch
cd /tmp/rxfetch
cp ttf-material-design-fonts/* $HOME/.local/share/fonts
fc-cache -fv
sudo mv rxfetch /usr/local/bin/rxfetch


# oh my posh for kitty with fish 
sudo wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/posh-linux-amd64 -O /usr/local/bin/oh-my-posh
sudo chmod +x /usr/local/bin/oh-my-posh

mkdir ~/.poshthemes
wget https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/themes.zip -O ~/.poshthemes/themes.zip
unzip ~/.poshthemes/themes.zip -d ~/.poshthemes
chmod u+rw ~/.poshthemes/*.omp.*
rm ~/.poshthemes/themes.zip


# hahahhahaha latte dock requirements
function latte() {
    sudo apt install -y autoconf baloo-kf5-dev intltool bison breeze-dev build-essential bzr cmake cmake-data debhelper dh-apparmor doxygen extra-cmake-modules flex fontforge gir1.2-gst-plugins-base-1.0 gir1.2-gstreamer-1.0 git gperf icu-devtools kded5-dev kgendesignerplugin kinit-dev kirigami2-dev kross-dev kscreenlocker-dev kwin-dev libaccounts-glib-dev libappstreamqt-dev libapr1 libaprutil1 libarchive-dev libasound2-dev libattr1-dev libboost-dev libbz2-dev libcanberra-dev libcap-dev libclang-dev libcln-dev libcups2-dev libcurl4-gnutls-dev libegl1-mesa-dev libepoxy-dev libexiv2-dev libfakekey-dev libfontconfig1-dev libfreetype6-dev libgbm-dev libgconf2-dev libgcrypt20-dev libgif-dev libglib2.0-dev libgmp-dev libgmpxx4ldbl libgpgme11-dev libgps-dev libgrantlee5-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev libgtk-3-dev libhunspell-dev libibus-1.0-dev libicu-dev  libjpeg-dev  libjson-perl libkaccounts-dev libkdecorations2-dev libkeduvocdocument-dev libkf5activities-dev libkf5activitiesstats-dev libkf5akonadicalendar-dev libkf5akonadicontact-dev libkf5akonadi-dev libkf5akonadimime-dev libkf5akonadinotes-dev libkf5akonadisearch-dev libkf5archive-dev libkf5attica-dev libkf5auth-dev libkf5baloowidgets-dev  libkf5bluezqt-dev libkf5bookmarks-dev libkf5calendarcore-dev libkf5calendarsupport-dev libkf5calendarutils-dev libkf5cddb-dev libkf5codecs-dev libkf5compactdisc-dev libkf5completion-dev libkf5config-dev libkf5configwidgets-dev libkf5contacteditor-dev libkf5contacts-dev libkf5coreaddons-dev libkf5crash-dev libkf5dbusaddons-dev libkf5declarative-dev libkf5dnssd-dev libkf5doctools-dev libkf5emoticons-dev libkf5eventviews-dev libkf5filemetadata-dev  libkf5globalaccel-dev libkf5grantleetheme-dev libkf5gravatar-dev libkf5guiaddons-dev libkf5holidays-dev libkf5i18n-dev libkf5iconthemes-dev libkf5identitymanagement-dev libkf5idletime-dev libkf5imap-dev libkf5incidenceeditor-dev libkf5itemmodels-dev libkf5itemviews-dev libkf5jobwidgets-dev libkf5jsembed-dev   libkf5kcmutils-dev libkf5kdcraw-dev libkf5kdegames-dev libkf5kdelibs4support-dev  libkf5kexiv2-dev libkf5khtml-dev libkf5kio-dev libkf5kipi-dev libkf5kjs-dev libkf5kmahjongglib-dev libkf5konq-dev libkf5kontactinterface-dev libkf5ksieve-dev libkf5ldap-dev libkf5libkdepim-dev libkf5libkleo-dev libkf5mailcommon-dev libkf5mailimporter-dev libkf5mailtransport-dev libkf5mbox-dev libkf5mediaplayer-dev libkf5mediawiki-dev libkf5messagecomposer-dev libkf5messagecore-dev libkf5messagelist-dev libkf5messageviewer-dev libkf5mime-dev libkf5mimetreeparser-dev libkf5networkmanagerqt-dev libkf5newstuff-dev libkf5notifications-dev libkf5notifyconfig-dev libkf5package-dev libkf5parts-dev libkf5people-dev libkf5pimcommon-dev libkf5pimtextedit-dev libkf5plasma-dev libkf5plotting-dev libkf5prison-dev libkf5pty-dev libkf5purpose-dev libkf5qqc2desktopstyle-dev libkf5runner-dev libkf5sane-dev libkf5screen-dev  libkf5service-dev libkf5solid-dev libkf5sonnet-dev libkf5style-dev libkf5su-dev libkf5syndication-dev libkf5syntaxhighlighting-dev libkf5sysguard-dev libkf5templateparser-dev libkf5texteditor-dev libkf5textwidgets-dev libkf5threadweaver-dev libkf5tnef-dev libkf5unitconversion-dev libkf5wallet-dev libkf5wayland-dev libkf5webengineviewer-dev libkf5webkit-dev libkf5widgetsaddons-dev libkf5windowsystem-dev libkf5xmlgui-dev libkf5xmlrpcclient-dev libktorrent-dev liblcms2-dev liblmdb-dev libmlt-dev libmlt++-dev libnm-dev libpackagekitqt5-dev libpam-dev libphonon4qt5-dev libphonon4qt5experimental-dev libpng-dev libpolkit-agent-1-dev libpolkit-gobject-1-dev libpulse-dev libpwquality-dev libqalculate-dev libqca-qt5-2-dev libqrencode-dev libqt5sensors5 libqt5sensors5-dev libqt5svg5-dev libqt5texttospeech5-dev libqt5webkit5-dev libqt5x11extras5-dev libqt5xmlpatterns5-dev libqt5networkauth5-dev libqt5waylandclient5-dev libraw1394-dev libscim-dev libserf-1-1 libsm-dev libssl-dev libsvn1 libtiff5-dev libudev-dev libusb-dev libvlccore-dev libvlc-dev libvncserver-dev libwww-perl libx11-dev libx11-xcb-dev libxapian-dev libxcb1-dev libxcb-composite0-dev libxcb-cursor0 libxcb-cursor-dev libxcb-damage0-dev libxcb-dpms0 libxcb-dpms0-dev libxcb-ewmh2 libxcb-ewmh-dev libxcb-image0-dev libxcb-keysyms1-dev libxcb-record0-dev libxcb-render-util0-dev libxcb-res0 libxcb-res0-dev libxcb-screensaver0 libxcb-screensaver0-dev libxcb-shm0-dev libxcb-util0-dev libxcb-xf86dri0 libxcb-xf86dri0-dev libxcb-xinerama0 libxcb-xinerama0-dev libxcb-xkb-dev libxcb-xtest0-dev libxcb-xv0 libxcb-xv0-dev libxcb-xvmc0 libxcb-xvmc0-dev libxcb-randr0-dev libxcursor-dev libxft-dev libxi-dev libxkbfile-dev libxml2-dev libxml-parser-perl libxrender-dev libxslt1-dev libxslt-dev llvm modemmanager-dev modemmanager-qt-dev network-manager-dev openbox oxygen-icon-theme  pkg-config pkg-kde-tools plasma-workspace-dev po-debconf qml-module-qtquick\* qt5-qmake qtbase5-dev qtbase5-dev-tools qtbase5-private-dev qtdeclarative5-dev qtmultimedia5-dev qtquickcontrols2-5-dev qtscript5-dev qttools5-dev qtxmlpatterns5-dev-tools shared-mime-info subversion texinfo xauth xcb-proto xserver-xorg-dev xserver-xorg-input-evdev-dev xserver-xorg-input-libinput-dev xserver-xorg-input-synaptics-dev xsltproc xvfb libkdsoap-dev
    sudo apt install cmake extra-cmake-modules qtdeclarative5-dev libqt5x11extras5-dev libkf5iconthemes-dev libkf5plasma-dev libkf5windowsystem-dev libkf5declarative-dev libkf5xmlgui-dev libkf5activities-dev build-essential libxcb-util-dev libkf5wayland-dev git gettext libkf5archive-dev libkf5notifications-dev libxcb-util0-dev libsm-dev libkf5crash-dev libkf5newstuff-dev libxcb-shape0-dev libxcb-randr0-dev libx11-dev libx11-xcb-dev kirigami2-dev libwayland-dev libwayland-client++1 plasma-wayland-protocols libqt5waylandclient5-dev qtwayland5-dev-tools -y
    git clone https://github.com/KDE/latte-dock.git /tmp/latte
    cd /tmp/latte
    sh install.sh
}
latte

# Kvantum
sudo apt install -y qt5-style-kvantum qt5-style-kvantum-themes


# Go packages
go install github.com/rs/curlie@latest

sudo reboot -f

