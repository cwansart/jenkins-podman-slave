# Jenkins Podman Slave
This image does not run any agent or such, but it prints the ssh key of the user "podman" which can be used in Jenkins to connect to. Do not use this image in production, it is for testing purpose only.

It tries to automatically connect to the Jenkins master using environment variables `JENKINS_SERVICE_HOST` and `JENKINS_SERVICE_PORT` via Jenkins CLI.

## Build

```
$ docker build -t cwansart/jenkins-podman-slave:1-autoconnect .
```

## Run

```
docker run --rm --name jenkins-podman-slave -e JENKINS_SERVICE_HOST=localhost -e JENKINS_SERVICE_PORT=8080 cwansart/jenkins-podman-slave:1-autoconnect
```

## Docker Image on Docker Hub

The Docker image can be found on: https://hub.docker.com/r/cwansart/jenkins-podman-slave
