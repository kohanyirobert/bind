#!/bin/bash
echo start

apt-get update
apt-get install --yes \
  bind9 \
  bind9-dnsutils \
  fail2ban \
  locales \
  mosh \
  psmisc \
  tmux

conf=/etc/bind/named.conf.local
test ! -f $conf && cp -v $conf $conf.orig
cat > $conf << EOF
zone "${domain}" {
%{~ if master }
  type master;
  file "db.${domain}";
  allow-transfer {
    ${ns2_ip};
  };
%{ else }
  type slave;
  file "db.${domain}";
  masters {
    ${ns1_ip};
  };
%{ endif ~}
};
EOF
%{ if master }
sudo -u bind -s << 'EOF1'
zone=/var/cache/bind/db.${domain}
cat > $zone << 'EOF2'
$TTL 1m
@   IN SOA ns1.${domain}. root.${domain}. (
           1  ; Serial
           1d ; Refresh
           1h ; Retry
           1w ; Expire
           1h ; Negative caching TTL
)

    IN NS  ns1.${domain}.
    IN NS  ns2.${domain}.

ns1 IN A   ${ns1_ip}
ns2 IN A   ${ns2_ip}
EOF2
EOF1
%{ endif }

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

systemctl enable bind9
systemctl enable fail2ban
systemctl restart bind9
systemctl restart fail2ban

echo end
