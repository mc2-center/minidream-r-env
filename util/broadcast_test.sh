#!/usr/bin/env bash
# Copy a module folder to all user home directories.
#
# $1 = module folder in shared space to be copied
# $2 = group name
#
# Usage:
# broadcast_module.sh /home/shared/modules/demo

SHARED_MODULE=$(realpath $1)
MODULE_NAME=$(basename $SHARED_MODULE)
GROUP=$2
echo "Group: $GROUP"
SKIP_USER=$3

GROUP_MEMBERS=$(getent group $GROUP)
echo $GROUP_MEMBERS
GROUP_MEMBERS=$(echo ${GROUP_MEMBERS##*:} | tr "," "\n")
echo $GROUP_MEMBERS
for user in $GROUP_MEMBERS; do
    if [[ "$user" != "$SKIP_USER" ]]; then
        echo "Copying '${SHARED_MODULE}' to user: ${user}"
    fi
done
