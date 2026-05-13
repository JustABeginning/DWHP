FROM alpine:latest
#
WORKDIR /app
COPY config/ ./
#
RUN apk update && \
    apk add wireguard-tools dbus tcpdump openssh net-tools iputils-ping ufw iptables busybox-suid
#
ARG WIREGUARD_DIR=/etc/wireguard
ARG SERVER_CONFIG=wg0.conf
ARG CLIENT_CONFIG=client.conf
RUN ls "${SERVER_CONFIG}" &> /dev/null && ls "${CLIENT_CONFIG}" &> /dev/null && \
    ufw allow 8080/tcp && \
    ufw allow 51820/udp && \
    wg genkey | tee server_private.key | wg pubkey > server_public.key && \
    chmod go= server_private.key && \
    wg genkey | tee client_private.key | wg pubkey > client_public.key && \
    chmod go= client_private.key && \
    cat server_private.key | while read line; \
    do sed -i "/PrivateKey/s|<>|$line|" "${SERVER_CONFIG}"; \
    done && \ 
    cat server_public.key | while read line; \
    do sed -i "/PublicKey/s|<>|$line|" "${CLIENT_CONFIG}"; \
    done && \ 
    cat client_private.key | while read line; \
    do sed -i "/PrivateKey/s|<>|$line|" "${CLIENT_CONFIG}"; \
    done && \ 
    cat client_public.key | while read line; \
    do sed -i "/PublicKey/s|<>|$line|" "${SERVER_CONFIG}"; \
    done && \
    echo "$(date +%s%N)$(dbus-uuidgen)" | sha1sum | cut -c 31- | while read line; \
    do export ipv6_prefix="fd${line:0:2}:${line:2:4}:${line:6:4}" && export ipv6_suffix="/64" && \
    sed -i "/Address/s|<>|$ipv6_prefix::1$ipv6_suffix|" "${SERVER_CONFIG}" && \
    sed -i "/AllowedIPs/s|<>|$ipv6_prefix::$ipv6_suffix|" "${SERVER_CONFIG}" && \
    sed -i "/Address/s|<>|$ipv6_prefix::2$ipv6_suffix|" "${CLIENT_CONFIG}"; \
    done && \
    sed -i "s/TODO/DONE/" "${SERVER_CONFIG}" && \
    ip route list | grep "src" | sed "s/.*src.//" | while read line; \
    do sed -i "/EndPoint/s|<>|$line|" "${CLIENT_CONFIG}"; \
    done && \
    sed -i "s/TODO/DONE/" "${CLIENT_CONFIG}" && \
    mv *.conf "${WIREGUARD_DIR}" && \
    mv *.key "${WIREGUARD_DIR}" && \
    export ufw_sysctl_conf='/etc/ufw/sysctl.conf' && \
    sed -i '/net\/ipv4\/ip_forward=1/s/#//' "$ufw_sysctl_conf" && \
    sed -i '/net\/ipv6\/conf\/all\/forwarding=1/s/#//' "$ufw_sysctl_conf" && \
    sed -i '/net\/ipv6\/conf\/default\/forwarding=1/s/#//' "$ufw_sysctl_conf" && \
    sysctl -p
#
ARG SSH_USER=root
ARG SSH_PASSWORD=admin
ARG ROOT_PASSWORD=admin
ARG SSH_CONFIG=/etc/ssh/sshd_config
RUN adduser -D -s /bin/sh ${SSH_USER} && \
    echo "${SSH_USER}:${SSH_PASSWORD}" | chpasswd && \
    echo "root:${ROOT_PASSWORD}" | chpasswd && \
    ssh-keygen -A && \
    ufw allow ssh && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "${SSH_CONFIG}" && \
    sed -i '/PermitRootLogin/s/yes/no/' "${SSH_CONFIG}" && \
    sed -i '/#Port 22/s/#//' "${SSH_CONFIG}" && \
    sed -i '/AllowTcpForwarding/s/no/yes/' "${SSH_CONFIG}" && \
    sed -i '/GatewayPorts/s/no/yes/' "${SSH_CONFIG}"
#
ENV CMD_COPY_CLIENT="cp \"${WIREGUARD_DIR}/${CLIENT_CONFIG}\" /app/storage"
ENTRYPOINT [ "sh", "-c", "eval \"$CMD_COPY_CLIENT\" && wg-quick up wg0 && /usr/sbin/sshd && ufw enable && sh" ]
