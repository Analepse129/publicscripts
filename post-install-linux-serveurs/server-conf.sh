#!/bin/bash
echo -e "\033[33m                                             _                         __ _       \033[0m"
echo -e "\033[33m                                            | |                       / _(_)      \033[0m"
echo -e "\033[33m  ___  ___ _ ____   _____ _ __    __ _ _   _| |_ ___   ___ ___  _ __ | |_ _  __ _ \033[0m"
echo -e "\033[33m / __|/ _ \ '__\ \ / / _ \ '__|  / _\` | | | | __/ _ \ / __/ _ \| '_ \|  _| |/ _\` |\033[0m"
echo -e "\033[33m \__ \  __/ |   \ V /  __/ |    | (_| | |_| | || (_) | (_| (_) | | | | | | | (_| |\033[0m"
echo -e "\033[33m |___/\___|_|    \_/ \___|_|     \__,_|\__,_|\__\___/ \___\___/|_| |_|_| |_|\__, |\033[0m"
echo -e "\033[33m                                                                             __/ |\033[0m"
echo -e "\033[33m                                                                            |___/ \033[0m"
echo -e "\033[33m                                                                                  \033[0m"
echo -e "\033[33m \033[0m"
if [[ $EUID -eq 0 ]]
then
# Récupération et génération des composantes
    newuserUsername="Admin"
    apps=('bat' 'sudo' 'ufw' 'glpi-agent' 'apt-transport-https' 'curl' 'wget' 'fonts-powerline' 'openssh-server' 'vim')
    ip_net="ip_net/mask"
    ip_zabbix="ip_zabbix"
    all_characters='a-zA-Z0-9''!@#$%^&*()-_=+[]{}|;:,.<>?'
    password=$(LC_CTYPE=C tr -dc $all_characters < /dev/urandom | fold -w 24 | head -n 1)
    interfaces=$(ip link show | grep -E '^[0-9]+: ' | awk '{print $2}' | sed 's/://')
# Mise à jour de l'OS
    echo -e "\033[33mMise à jour du système...\n\033[0m"
    apt update >/dev/null 2>&1
    apt upgrade -y >/dev/null 2>&1
# Installation des paquets dans les dépots
    echo -e "\033[33mLancement de l'installation des paquets...\n\033[0m"
    for app in "${apps[@]}"
    do
        echo -e "\033[33mInstalling "$app"...\033[0m"
        apt install -y $app >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo -e "\033[32m"$app" installé avec succès !\033[0m"
        else
            echo -e "\033[31mErreur lors de l'installation de "$app".\033[0m"
        fi
    done
# Désactivation de l'accès SSH pour root
    echo -e "\033[33mDésactivation de l'accès SSH pour root...\033[0m"
    sudo sed -i 's/PermitRootLogin yes/PermitRootLogin no/g' /etc/ssh/sshd_config >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
    service ssh restart
# Création dde l'utilisateur $newuserUsername
    echo -e "\033[33mCréation de l'utilisateur $newuserUsername...\033[0m"
    useradd -m -s /bin/bash $newuserUsername >/dev/null 2>&1
    echo -e "$password\n$password" | passwd $newuserUsername >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
# Ajout de l'utilisateur newuserUsername au groupe sudo
    echo -e "\033[33mAjout de l'utilisateur $newuserUsername au groupe "sudo"...\033[0m"
    usermod -aG sudo $newuserUsername >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
# Désactivation de l'IPv6 dans l'OS
    echo -e "\033[33mDésactivation de l'IPv6...\033[0m"
    echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
    echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
    echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
    sysctl -p >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mIPv6 désactivé sur l'OS.\033[0m"
    else
        echo -e "\033[31mErreur lors de la désactivation d'IPv6 sur l'OS.\033[0m"
    fi
# Désactivation du support IPv6 dans UFW
    sed -i 's/IPV6=yes/IPV6=no/g' /etc/default/ufw
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mIPv6 désactivé dans UFW.\033[0m"
    else
        echo -e "\033[31mErreur lors de la désactivation d'IPv6 dans UFW.\033[0m"
    fi
# Définition des règles de firewall
    echo -e "\033[33mCréation des règles de firewall...\033[0m"
    echo -e "SSH...\033[0m"
    uwf allow from $ip_net proto tcp to any port 22 >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mOk\033[0m"
    else
        echo -e "\033[31mErreur\033[0m"
    fi
    systemctl enable ufw >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mRègles de firewall crées !\033[0m"
    else
        echo -e "\033[31mErreur lors de la création des règles.\033[0m"
    fi
# Installation et configuration de "Oh-My-Bash" pour tous les utilisateurs de la machine
    usernames=($(awk -F: '$7 ~ /(\/bin\/bash|\/bin\/sh)/ {print $1}' /etc/passwd))
    for ((i = 0; i < ${#usernames[@]}; i++))
    do
        echo -e "\033[33mConfiguration de "Oh-My-Bash" pour  ${username[i]}\033[0m"
        su  ${username[i]}
        bash -c "$(wget https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh -O -)" >/dev/null 2>&1
        sed -i 's/OSH_THEME="font"/OSH_THEME="agnoster"/g' ~/.bashrc
        sleep 1s
        sed -i 's/OMB_USE_SUDO=true/OMB_USE_SUDO=false/g' ~/.bashrc
        sleep 1s
    done
# Affichage des informations et validation
    su root
    echo -e "\033[33mInformations à conserver précieusement : \033[0m"
    echo -e "   1. Utilisateur newuserUsername : $password"
    echo -e "   2. Règles de firewall définies :"
    ufw status numbered
    echo -e "   3. Vos adresses IP : "
    ip -br -c addr
# Purge des paquets et redémarrage
    echo -e "\033[33mPurge des paquets inutiles...\033[0m"
    apt autoremove -y --purge >/dev/null 2>&1
    echo -e "\033[33mLa machine va redémarrer dans 5 secondes...\033[0m"
    sleep 5s
    shutdown -r now
else
    echo "\033[31mExecutez en root !\033[0m"
fi
exit