#!/bin/bash
ZABBIX_SERVER="IP_OR_DNS_NAME"

cd /tmp
wget https://repo.zabbix.com/zabbix/6.0/debian/pool/main/z/zabbix-release/zabbix-release_6.0-4%2Bdebian11_all.deb
dpkg -i zabbix-release_6.0-4+debian11_all.deb
apt update && apt install zabbix-agent -y
sed -i "s/Server=127.0.0.1/Server=$ZABBIX_SERVER/g" /etc/zabbix/zabbix_agentd.conf
sleep 1s
sed -i "s/ServerActive=127.0.0.1/ServerActive=$ZABBIX_SERVER/g" /etc/zabbix/zabbix_agentd.conf
sleep 1s
sed -i "s/Hostname=Zabbix server/Hostname=$HOSTNAME/g" /etc/zabbix/zabbix_agentd.conf
sleep 1s
sed -i 's/# HostMetadata=/HostMetadata=linux/g' /etc/zabbix/zabbix_agentd.conf
sleep 1s
rm zabbix-release_6.0-4+debian11_all.deb
ufw allow from $ZABBIX_SERVER to any port 10050
systemctl restart zabbix-agent
systemctl enable zabbix-agent