#!/bin/bash
query() {
  key=$1
  curl -H "Metadata-Flavor: Google" \
    http://metadata.google.internal/computeMetadata/v1/instance/attributes/$key
}

echo start
useradd --create-home --shell /bin/bash duckdns
duckdns_token=$(query duckdns_token)
duckdns_domain=$(query duckdns_domain)
cat > /home/duckdns/duck.sh << EOF
url='https://www.duckdns.org/update?token=$duckdns_token&domains=$duckdns_domain&ip='
message=\$(curl --silent \$url)
logger \$message
EOF
chown duckdns:duckdns /home/duckdns/duck.sh
chmod u=rwx,g=,o= /home/duckdns/duck.sh
crontab -u duckdns - << EOF
*/5 * * * * ~/duck.sh > /dev/null 2>&1
EOF
sudo -u duckdns sh -c '~/duck.sh > /dev/null 2>&1'
apt-get update
apt-get install --yes \
  bind9 \
  bind9-dnsutils \
  fail2ban
systemctl enable bind9
systemctl enable fail2ban
systemctl start bind9
systemctl start fail2ban
echo end
