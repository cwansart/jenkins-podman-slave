FROM fedora:31

COPY jenkins-podman-slave-start.sh /start.sh

RUN dnf -y update && \
    dnf install -y podman openssh openssh-server && \
    dnf clean all && \
    ln -s /usr/local/bin/podman /usr/bin/docker && \
    ssh-keygen -A && \
    sed -i 's/PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo 'PermitRootLogin without-password' >> /etc/ssh/sshd_config

RUN useradd -ms /bin/bash podman
USER podman
WORKDIR /home/podman
RUN ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa

USER root
EXPOSE 22
CMD ["sh", "/start.sh"]