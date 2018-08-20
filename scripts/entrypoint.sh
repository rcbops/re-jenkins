#!/usr/bin/env bash
# This script is a wrapper around the normal startup script. It's purpose is to dump some diagnostic information
# to aid in troubleshooting.

# Load a few helper scripts
for i in colors logger utils; do 
  . ${i}.sh
done

# General user account workaround when running on OpenShift.
# Because the user ID of the container is generated dynamically, it will not have an associated entry in /etc/passwd.
# This can cause problems for applications that expect to be able to look up their user ID. One way to address this
# problem is to dynamically create a passwd file entry with the container’s user ID as part of the image’s start script.
function addCurrentUser(){
  log "Calling addCurrentUser()..."
  log "My \$USER_NAME=${USER_NAME}"
  log "My \$HOME=${HOME}"

  ID=$(id -u)
  if [[ $? -eq 0 ]]; then
    log "User ID is: ${ID}"
  else
    log_warn "id -u fails - probably because no /etc/passwd entry."

    echo "Gonna split on: `id`"
    echo "Splitting by: <space>"
    IFS=' ' read -ra arr <<< `id` # example output: uid=1001340000 gid=0(root) groups=0(root),1001340000
    echo "arr    : ${arr}"
    echo "arr[0] : ${arr[0]}"
    echo "arr[1] : ${arr[1]}"

    echo "Splitting by: ="
    IFS='=' read -ra arr <<< "${arr[0]}"
    echo "arr[0] : ${arr[0]}"
    echo "arr[1] : ${arr[1]}"
    ID="${arr[1]}"
  fi

  log "Using ID:${ID}"

  log "/etc/passwd is:"
  cat /etc/passwd
}

function showDirectoryPermissions(){
  # Show some directory permissions
  for i in /usr/share/jenkins /var/jenkins_home; do
    log "Directory permissions for: ${i}"
    ls -lad ${i}
  done
}

function setDirectoryPermissions(){
  log "Directory permissions before:"
  showDirectoryPermissions

  # Re-setting directory permissions
  log "Resetting directory permissions..."
  chown -R `id -u`:0 /usr/share/jenkins /var/jenkins_home
  chmod -R ug+rwx /usr/share/jenkins /var/jenkins_home
  #  chgrp -R root /usr/share/jenkins /var/jenkins_home && \
  #  chmod -R ug+rwx /usr/share/jenkins /var/jenkins_home

  log "Directory permissions after:"
  showDirectoryPermissions
}

function showUserInfo(){
  # Show the current user's ID and group information
  log "User Info:"
  id
  id -u
}

function showContainerSizeInfo(){
  log "CPU and Memory information:"
  cat /proc/cpuinfo | grep processor | wc -l
  cat /proc/meminfo | head -1
}

function showMounts(){
  log "Mounts:"
  mount
  log "lvm info:"
  lvs
  pvs
  vgs
}

function showNetworking(){
  log "Hosts:"
  cat /etc/hosts
  echo ""
  log "resolv.conf:"
  cat /etc/resolv.conf
  echo ""
}

showUserInfo
#addCurrentUser
setDirectoryPermissions
showContainerSizeInfo
showMounts
showNetworking

# Test permissions
tf="/var/jenkins_home/tf"
log "Test writing ${tf}"
date > ${tf}
log "Test reading ${tf}"
cat ${tf}

# Now launch Jenkins (see jenkinsci/docker)
log "Launching Jenkins..."
/sbin/tini -s -- /usr/local/bin/jenkins.sh
