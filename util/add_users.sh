#!/bin/bash

# bash /path/to/file.csv
function join_by { local IFS="$1"; shift; echo "$*"; }

while read line; do
  a=($(echo "$line" | tr ',' '\n'))
  b=($(echo "${a[2]}" | tr ';' '\n'))
  # add the user
  useradd -m -p $(openssl passwd -crypt "${a[1]}") -s /bin/bash "${a[0]}"
  usermod -a -G $(join_by , "${b[@]}") "${a[0]}"
done < "$1"
