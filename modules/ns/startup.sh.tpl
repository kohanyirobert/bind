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

conf_options=/etc/bind/named.conf.options
test ! -f $conf_options.orig && cp -v $conf_options $conf_options.orig
cat > $conf_options << EOF
options {
  directory "/var/cache/bind";
  dnssec-validation auto;
  allow-transfer {
    key ${ns1_ns2_key_name};
  };
  listen-on-v6 {
    none;
  };
};
EOF

conf_local=/etc/bind/named.conf.local
test ! -f $conf_local.orig && cp -v $conf_local $conf_local.orig
cat > $conf_local << EOF
include "/etc/bind/${ns1_ns2_key_name}.key";
%{ if master ~}
include "/etc/bind/${ddns_key_name}.key";
%{ endif ~}

server %{ if master }${ns2_ip}%{ else }${ns1_ip}%{ endif } {
  keys {
    ${ns1_ns2_key_name};
  };
};

zone "${domain}" {
%{~ if master }
  type master;
  file "db.${domain}";
  update-policy {
    grant ${ddns_key_name} zonesub ANY;
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

reference_key=/etc/bind/rndc.key

ns1_ns2_key=/etc/bind/${ns1_ns2_key_name}.key
cat > $ns1_ns2_key << 'EOF'
${ns1_ns2_key ~}
EOF
chown -v --reference=$reference_key $ns1_ns2_key
chmod -v --reference=$reference_key $ns1_ns2_key

%{ if master ~}
ddns_key=/etc/bind/${ddns_key_name}.key
cat > $ddns_key << 'EOF'
${ddns_key ~}
EOF
chown -v --reference=$reference_key $ddns_key
chmod -v --reference=$reference_key $ddns_key

sudo -u bind -s << 'EOF1'
cat > /var/cache/bind/db.${domain} << 'EOF2'
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
%{ endif ~}

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

systemctl enable bind9
systemctl enable fail2ban
systemctl restart bind9
systemctl restart fail2ban

echo end
