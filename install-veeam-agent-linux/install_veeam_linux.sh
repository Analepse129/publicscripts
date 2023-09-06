#!/bin/bash
echo -e "\033[33m                                                             _       \033[0m"
echo -e "\033[33m                                                            | |      \033[0m"
echo -e "\033[33m    __   _____  ___  __ _ _ __ ___     __ _  __ _  ___ _ __ | |_     \033[0m"
echo -e "\033[33m    \ \ / / _ \/ _ \/ _\` | '_ \` _ \   / _\` |/ _\` |/ _ \ '_ \| __|    \033[0m"
echo -e "\033[33m     \ V /  __/  __/ (_| | | | | | | | (_| | (_| |  __/ | | | |_     \033[0m"
echo -e "\033[33m      \_/ \___|\___|\__,_|_| |_| |_|  \__,_|\__, |\___|_| |_|\__|    \033[0m"
echo -e "\033[33m                                             __/ |                   \033[0m"
echo -e "\033[33m                                            |___/                    \033[0m"
echo -e "\033[33m     _      _     _               _           _        _ _           \033[0m"
echo -e "\033[33m    | |    | |   (_)             (_)         | |      | | |          \033[0m"
echo -e "\033[33m  __| | ___| |__  _  __ _ _ __    _ _ __  ___| |_ __ _| | | ___ _ __ \033[0m"
echo -e "\033[33m / _\` |/ _ \ '_ \| |/ _\` | '_ \  | | '_ \/ __| __/ _\` | | |/ _ \ '__|\033[0m"
echo -e "\033[33m| (_| |  __/ |_) | | (_| | | | | | | | | \__ \ || (_| | | |  __/ |   \033[0m"
echo -e "\033[33m \__,_|\___|_.__/|_|\__,_|_| |_| |_|_| |_|___/\__\__,_|_|_|\___|_|   \033[0m"
echo -e "\033[33m                                                                     \033[0m"
if [[ $EUID -eq 0 ]]
then
    apps=( 'dkms' 'lvm2' )
    declare -A telechargements
    telechargements=( 
        [blksnap_6.0.3.1221_all.deb]="https://repository.veeam.com/backup/linux/agent/dpkg/debian/public/pool/veeam/b/blksnap/blksnap_6.0.3.1221_all.deb" 
        [veeam_6.0.3.1221_amd64.deb]="https://repository.veeam.com/backup/linux/agent/dpkg/debian/public/pool/veeam/v/veeam/veeam_6.0.3.1221_amd64.deb"
     )

# Mise à jour des listes de paquets
    echo -e "\033[33m\nMise à jour du système...\033[0m"
    sleep 1s
    apt update >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
        echo -e "\033[32mListe des paquets à jour.\033[0m"
    else
        echo -e "\033[31mErreur lors de la mise à jour.\033[0m"
    fi
# Installation des prérequis
    echo -e "\033[33m\nLancement de l'installation des dépendances...\033[0m"
    sleep 1s
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
# Téléchargements des paquets Veeam...
    echo -e "\033[33m\nLancement des téléchargements des prérequis...\033[0m"
    sleep 1s
    if [ ! -d "/tmp/veeam" ]
    then
        mkdir /tmp/veeam
    fi
    cd /tmp/veeam
    for app in "${!telechargements[@]}"
    do
        echo -e "\033[33mTéléchargement de "$app"...\033[0m"
        wget ${telechargements[$app]} >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo -e "\033[32mOk\033[0m"
        else
            echo -e "\033[31mErreur lors du téléchargement de "$app".\033[0m"
        fi
    done
# Installation de Veeam
    echo -e "\033[33m\nInstallation des paquets téléchargés...\033[0m"
    sleep 1s
    for app in "${!telechargements[@]}"
    do
        echo -e "\033[33mInstallation de "$app"...\033[0m"
        dpkg -i $app >/dev/null 2>&1
        if [ $? -eq 0 ]
        then
            echo -e "\033[32mOk\033[0m"
        else
            echo -e "\033[31mErreur lors de l'installation du paquet "$app".\033[0m"
        fi
    done
# suppression du dossier temporaire
    rm -dR /tmp/veeam
    cd ~/
# Lancement de la configuration
    veeam
else
    echo "\033[31mExecutez en root !\033[0m"
fi
exit

