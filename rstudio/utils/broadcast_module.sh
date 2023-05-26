#!/usr/bin/env bash
# Copy a module folder to all user home directories.
#
# $1 = module folder in shared space to be copied
# $2 = group name
#
# Usage:
# broadcast_module.sh /home/shared/modules/module0 rstudio-user

SHARED_MODULE=$(realpath $1)
MODULE_NAME=$(basename $SHARED_MODULE)
GROUP=$2
SKIP_USER=$3

GROUP_MEMBERS=$(getent group $GROUP)
GROUP_MEMBERS=$(echo ${GROUP_MEMBERS##*:} | tr "," "\n")
for user in $GROUP_MEMBERS; do
    if [[ "$user" != "$SKIP_USER" ]]; then
        echo "Copying '${SHARED_MODULE}' to user: ${user}"
        user_home="/home/${user}"
        user_modules="${user_home}/modules"
        if [[ ! -e "$user_modules" ]]; then
            sudo mkdir -p $user_modules
        fi

        sudo rsync -ur $SHARED_MODULE $user_modules
        sudo chown -R "${user}":rstudio-admin $user_modules
        sudo find "${user_modules}/${MODULE_NAME}" \
            -name "session-persistent-state" \
            | sudo xargs -I {} rm -f {}
        sudo find "${user_modules}/${MODULE_NAME}" \
            -type d \
            -name ".Rproj.user" \
            | xargs -I {} sudo rm -rf {}
        sudo rm -f ${user_modules}/${MODULE_NAME}/*.nb.html
    fi
done
