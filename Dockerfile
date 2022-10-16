# syntax=docker/dockerfile:1
FROM alpine:3.16 AS builder
WORKDIR /root
ENV GOPATH /root/go
RUN <<EOF
  apk add go git cmake make
  mkdir -p /rootfs/opt
  # tcp-proxy-tunnel
  git clone https://github.com/lutfailham96/go-tcp-proxy-tunnel && cd go-tcp-proxy-tunnel
  go build -ldflags="-w -s" -o /rootfs/opt/tcp-proxy-tunnel cmd/tcp-proxy-tunnel/main.go
  cd ..
  # badvpn-udpgw
  git clone https://github.com/ambrop72/badvpn
  cmake -S badvpn -B badvpn/build -DBUILD_NOTHING_BY_DEFAULT=1 -DBUILD_UDPGW=1 -DCMAKE_RUNTIME_OUTPUT_DIRECTORY=/rootfs/opt
  cmake --build badvpn/build
EOF

FROM alpine:3.16
RUN <<EOF
  apk add --no-cache openssh dropbear squid stunnel openvpn openssl
  apk add --no-cache --repository https://dl-cdn.alpinelinux.org/alpine/edge/testing shadowsocks-libev sslh
  apk add --no-cache supervisor micro
  add-shell /bin/false
  adduser -D -s /bin/false freeinternet
  echo "freeinternet:freeinternet" | chpasswd
  # OpenSSH
  ssh-keygen -A
  # stunnel: create certificate
  DAYS=$(( (`date -d "2038-01-01" +%s` - `date -d "00:00" +%s`) / (24*3600) ))
  openssl req -new -x509 -days $DAYS -nodes -out /etc/stunnel/stunnel.pem -keyout /etc/stunnel/stunnel.pem -subj "/C=ZZ/ST=Phreaking/O=Phreaking"
  
EOF

COPY rootfs /
COPY --from=builder /rootfs /

CMD [ "/usr/bin/supervisord", "-c", "/etc/supervisord.conf" ]
