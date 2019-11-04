FROM fedora:31

RUN dnf -y update && \
    dnf install -y podman openssh openssh-server java-1.8.0-openjdk-devel \
                   net-tools maven git crudini && \
    dnf clean all && \
    ln -s /usr/bin/podman /usr/bin/docker && \
    ssh-keygen -A

WORKDIR /var/jenkins_home

COPY credentials.xml ./autoconnect/
COPY slave.xml ./autoconnect/

COPY tini_pub.gpg ${JENKINS_HOME}/tini_pub.gpg
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v0.18.0/tini-amd64 -o /sbin/tini && \
  curl -fsSL https://github.com/krallin/tini/releases/download/v0.18.0/tini-amd64.asc -o /sbin/tini.asc && \
  gpg --no-tty --import ${JENKINS_HOME}/tini_pub.gpg && \
  gpg --verify /sbin/tini.asc && \
  rm -rf /sbin/tini.asc /root/.gnupg && \
  chmod +x /sbin/tini && \
  echo "root:root" | chpasswd && \
  echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

EXPOSE 22

COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["/sbin/tini", "--", "docker-entrypoint.sh"]
CMD ["/usr/sbin/sshd", "-D"]
