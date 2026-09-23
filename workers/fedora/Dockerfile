FROM fedora:latest

RUN dnf install -y openssh-server sudo python3 python3-libdnf5 && \
    ssh-keygen -A && \
    useradd -m -s /bin/bash fedora && \
    echo 'fedora ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/fedora && \
    chmod 440 /etc/sudoers.d/fedora && \
    mkdir -p /home/fedora/.ssh && \
    chown -R fedora:fedora /home/fedora/.ssh && \
    chmod 700 /home/fedora/.ssh && \
    dnf clean all

CMD ["/usr/sbin/sshd", "-D"]