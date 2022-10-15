# syntax=docker/dockerfile:1

FROM alpine:3.16
RUN <<EOF
  apk add --no-cache openssh dropbear squid stunnel openvpn openssl nodejs
  apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing shadowsocks-libev sslh
  apk add --no-cache supervisor micro xbps
  add-shell /bin/false
  adduser -D -s /bin/false freeinternet
  echo "freeinternet:freeinternet" | chpasswd
  # OpenSSH
  ssh-keygen -A
  # BadVPN-UDPGW: todo: don't use xbps, compile in alpine correctly
  mkdir /etc/xbps.d
  echo "repository=https://repo-default.voidlinux.org/current/musl" > /etc/xbps.d/00-repository-main.conf
  xbps-install -Sy badvpn
  rm /var/cache/xbps/*
  # stunnel: create certificate
  DAYS=$(( (`date -d "2038-01-01" +%s` - `date -d "00:00" +%s`) / (24*3600) ))
  openssl req -new -x509 -days $DAYS -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=ZZ/ST=Phreaking/O=Phreaking"
  
EOF

COPY rootfs /
CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
