#!/bin/bash
echo start

flag_file=/root/.ran-gce-startup-script
if [ -f $flag_file ]
then
  echo skip
  exit 0
fi

backup_file() {
  local file="$1"
  if [ ! -f "$1".orig ]
  then
    cp -v "$1" "$1".orig
  fi
}

apt-get update
apt-get install --yes \
  bind9 \
  bind9-dnsutils \
  fail2ban \
  locales \
  mosh \
  psmisc \
  tmux

pushd /etc/bind
conf=named.conf.local
backup_file $conf
cat > $conf << EOF
zone "${domain}" {
%{~ if master }
  type master;
  // NOTE: mind the absolute path
  file "/etc/bind/db.${domain}";
  allow-transfer {
    ${ns2_ip};
  };
%{ else }
  type slave;
  // NOTE: mind the relative path
  file "db.${domain}";
  masters {
    ${ns1_ip};
  };
%{ endif ~}
};
EOF
%{ if master }
cat > db.${domain} <<'EOF'
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
EOF
%{ endif }
popd

sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
locale-gen

systemctl enable bind9
systemctl enable fail2ban
systemctl restart bind9
systemctl restart fail2ban

touch $flag_file

echo end
