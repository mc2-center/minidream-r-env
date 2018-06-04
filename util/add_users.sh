#!/bin/bash

# bash /path/to/file.csv

while read line; do
  a=($(echo "$line" | tr ',' '\n'))
  b=($(echo "${a[2]}" | tr ';' '\n'))
  # add the user
  useradd -m -p $(openssl passwd -crypt "${a[1]}") -g "${b[0]}" -G "${b[1]}" -s /bin/bash "${a[0]}"

done <"$1"

