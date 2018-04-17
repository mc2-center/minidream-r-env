#!/usr/bin/env bash
# Add new admin users
#
# $@ = list of admin user IDs
#
# Usage:
# add_users.sh admin1 admin2 ...

ADMINS="$@"

for admin in $ADMINS; do
   echo "Adding admin: ${admin}"
   sudo useradd -m -g rstudio-user -G rstudio-admin -s /bin/bash $admin
   echo "${admin}:csbc" | sudo chpasswd
done
