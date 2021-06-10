#!/usr/bin/env bash
# Copy RStudio user settings to a new user from an example user
#
# $1 = example RStudio user settings directory
# $2 = group name
#
# Usage:
# broadcast_settings.sh /home/jeddy/.rstudio

SETTINGS=$1
GROUP=$2

echo "Terminating active R sessions..."
#sudo pkill rsession
sudo rstudio-server kill-all

BASE_USER=$(basename $(dirname $SETTINGS))
echo "Original user: ${BASE_USER}"

GROUP_MEMBERS=$(getent group $GROUP)
GROUP_MEMBERS=$(echo ${GROUP_MEMBERS##*:} | tr "," "\n")
for user in $GROUP_MEMBERS; do
    if [[ "$user" != "jeddy" ]]; then
        echo "Copying '${SETTINGS}' to user: ${user}"
        user_home="/home/${user}"
        sudo rm -rf ${user_home}/.rstudio
        sudo cp -r $SETTINGS $user_home
        sudo chown -R "${user}":rstudio-admin $user_home
        sudo find "$user_home/.rstudio" \
            -mindepth 1 -maxdepth 1 \
            -name "session-persistent-state" \
            | sudo xargs -n 1 -I{} rm {}
    fi
done
