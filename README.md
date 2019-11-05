# Jenkins Podman Slave
This image does not run any agent or such, but it prints the ssh key of the user "podman" which can be used in Jenkins to connect to. Do not use this image in production, it is for testing purpose only.

It tries to automatically connect to the Jenkins master using the dns name `jenkis` on the port `10080` via Jenkins CLI.

## Build

```
$ docker build -t cwansart/jenkins-podman-slave:1-autoconnect .
```

## Run

```
docker run --rm --name jenkins-podman-slave cwansart/jenkins-podman-slave:1-autoconnect
```

## Docker Image on Docker Hub

The Docker image can be found on: https://hub.docker.com/r/cwansart/jenkins-podman-slave
