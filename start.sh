#!/bin/sh

echo "private ssh key file for user podman:"
cat /home/podman/.ssh/id_rsa

/usr/sbin/sshd -D