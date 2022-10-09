# syntax=docker/dockerfile:1
FROM alpine:3.16
RUN <<EOF
  apk add --no-cache nginx dropbear squid stunnel openvpn openssl easy-rsa
  apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/latest-stable/main shadowsocks-libev
  apk add --no-cache supervisor
  add-shell /bin/false
  adduser -D -s /bin/false freeinternet
  echo "freeinternet:freeinternet" | chpasswd
  # Stunnel certificate
  DAYS=$(( (`date -d "2038-01-01" +%s` - `date -d "00:00" +%s`) / (24*3600) ))
  openssl req -new -x509 -days $DAYS -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=ZZ/ST=Phreaking/O=Phreaking"
  
EOF

COPY rootfs /
CMD ["/opt/start.sh"]
