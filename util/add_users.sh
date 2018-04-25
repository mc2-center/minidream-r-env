#!/bin/bash

# bash /path/to/file.csv

while read line; do
  a=($(echo "$line" | tr ',' '\n'))

  # add the user
  useradd -m -p $(openssl passwd -crypt "${a[1]}") -s /bin/false "${a[0]}"

  # other user specific stuff here

done <"$1"
