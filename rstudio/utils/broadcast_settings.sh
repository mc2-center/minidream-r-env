#!/usr/bin/env bash
# Copy RStudio user settings to a new user from an example user
#
# $1 = Source user
# $2 = Target group name
#
# Usage:
# broadcast_settings.sh bgrande rstudio-user

BASE_USER=$1
GROUP=$2

echo "Terminating active R sessions..."
#sudo pkill rsession
sudo rstudio-server kill-all

# BASE_USER=$(basename $(dirname $SETTINGS))
echo "Source user: ${BASE_USER}"

SETTINGS="/home/${BASE_USER}/.config/rstudio/rstudio-prefs.json"

GROUP_MEMBERS=$(getent group $GROUP)
GROUP_MEMBERS=$(echo ${GROUP_MEMBERS##*:} | tr "," "\n")

for user in $GROUP_MEMBERS; do
    if [[ "$user" != "${BASE_USER}" ]]; then
        echo "Copying '${SETTINGS}' to user: ${user}"
        user_settings="/home/${user}/.config/rstudio/rstudio-prefs.json"
        mkdir -p $(dirname "${user_settings}")
        sudo rm -f "${user_settings}"
        sudo cp "${SETTINGS}" "${user_settings}"
        sudo chown -R "${user}":rstudio-admin "/home/${user}"
    fi
done
