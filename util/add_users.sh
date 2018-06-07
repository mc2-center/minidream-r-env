#!/bin/bash

# bash /path/to/file.csv
function join_by { local IFS="$1"; shift; echo "$*"; }

while read line; do
  a=($(echo "$line" | tr ',' '\n'))
  b=($(echo "${a[2]}" | tr ';' '\n'))
  getent passwd "${a[0]}" > /dev/null
  if [ $? -eq 0 ]; then
    # add the user
    useradd -m -p $(openssl passwd -crypt "${a[1]}") -s /bin/bash "${a[0]}"
    usermod -a -G $(join_by , "${b[@]}") "${a[0]}"
  else
    echo "User ${a[0]} already exists; skipping."
  fi
done < "$1"
