#!/bin/bash

# bash /path/to/file.csv
function join_by { local IFS="$1"; shift; echo "$*"; }

while read line; do
  a=($(echo "$line" | tr ',' '\n'))
  b=($(echo "${a[2]}" | tr ';' '\n'))
  getent passwd "${a[0]}" > /dev/null
  if [ $? -eq 0 ]; then
    echo "User ${a[0]} already exists; skipping."
  else
    # add the user
    user="${a[0]}"
    userpass="${a[1]}"
    groupstr=$(join_by , "${b[@]}")
    echo "Adding user $user to groups $groupstr"
    useradd -m -p $(openssl passwd -5 $userpass) -s /bin/bash $user
    usermod -a -G $groupstr $user
  fi
done < "$1"
