#!/bin/sh
# This script is a wrapper around the normal startup script. It's purpose is to dump some diagnostic information
# to aid in troubleshooting.

# General user account workaround when running on OpenShift.
# Because the user ID of the container is generated dynamically, it will not have an associated entry in /etc/passwd.
# This can cause problems for applications that expect to be able to look up their user ID. One way to address this
# problem is to dynamically create a passwd file entry with the container’s user ID as part of the image’s start script.
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    echo "${USER_NAME:-default}:x:$(id -u):0:${USER_NAME:-default} user:${HOME}:/bin/bash" >> /etc/passwd
  fi
fi

echo "ID:"
id

for i in /usr/share/jenkins /var/jenkins_home; do
  echo "Directory permissions for: ${i}"
  ls -lad ${i}
done

echo "CPUs:"
cat /proc/cpuinfo | grep processor | wc -l

echo "Memory:"
cat /proc/meminfo | head -1

echo "Mounts:"
mount

tf="/var/jenkins_home/tf"
echo "Test writing ${tf}"
date > ${tf}
echo "Test reading ${tf}"
cat ${tf}
echo "lvm info:"
lvs
pvs
vgs
echo "Hosts:"
cat /etc/hosts
echo "resolv.conf:"
cat /etc/resolv.conf

# Now launch Jenkins (see jenkinsci/docker)
/sbin/tini -s -- /usr/local/bin/jenkins.sh
