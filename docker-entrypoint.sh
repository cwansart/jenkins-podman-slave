#!/bin/bash

is_jenkins_master_up() {
  status=$(curl -s -o /dev/null -w "%{http_code}" $1)
  echo "Response status is: $status"
  if [[ "$status" -eq 200 ]]; then
    return 0
  else
    return 1
  fi
}

autoconnect() {
  MAX_TRIES=30
  connect_counter=0

  while ! is_jenkins_master_up $1 && [[ $connect_counter -lt $MAX_TRIES ]]; do
    ((connect_counter++))
    echo "Attempt $connect_counter"
    sleep 3
  done

  if [[ $connect_counter -eq $MAX_TRIES ]]; then
    echo "Failed after $MAX_TRIES attempts to connect to the Jenkins master."
    echo "Slave won't attempt to automatically connect again."
    return
  fi

  echo "Jenkins master is running. Adding node..."

  TRUST_FILE_ALGORITHM=$(cat /etc/ssh/ssh_host_rsa_key.pub |awk '{print $1}')
  TRUST_FILE_KEY=$(cat /etc/ssh/ssh_host_rsa_key.pub |awk '{print $2}')
  sed "s#<algorithm></algorithm>#<algorithm>${TRUST_FILE_ALGORITHM}</algorithm>#g" -i autoconnect/slave.xml
  sed "s#<name>podman</name>#<name>podman-${HOSTNAME}</name>#g" -i autoconnect/slave.xml

  CONTAINER_IP_ADDRESS=$(/sbin/ifconfig eth0 | grep inet | awk -F'[: ]+' '{ print $3 }')
  sed "s#<key></key>#<key>${TRUST_FILE_KEY}</key>#g" -i autoconnect/slave.xml

  echo "Downloading Jenkins cli"
  curl -o cli.jar $1/jnlpJars/jenkins-cli.jar
  echo "Adding credentials"
  java -jar cli.jar -s $1 create-credentials-by-xml system::system::jenkins _ < autoconnect/credentials.xml
  echo "Adding node"
  java -jar cli.jar -s $1 create-node < autoconnect/slave.xml

  echo "Adding Nexus to insecure registries"
  crudini --set /etc/containers/registries.conf registries.insecure registries "['nexus:10080']"
  echo "Done configuring, have fun."
}

JENKINS_URL="http://jenkins:10080"
echo "Trying to auto connect to Jenkins master on $JENKINS_URL"
autoconnect $JENKINS_URL

exec "$@"
