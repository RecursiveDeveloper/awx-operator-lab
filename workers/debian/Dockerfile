FROM debian:latest

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server sudo python3 && \
    ssh-keygen -A && \
    useradd -m -s /bin/bash debian && \
    echo 'debian ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/debian && \
    chmod 440 /etc/sudoers.d/debian && \
    mkdir -p /home/debian/.ssh && \
    chown -R debian:debian /home/debian/.ssh && \
    chmod 700 /home/debian/.ssh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

CMD ["/usr/sbin/sshd", "-D"]